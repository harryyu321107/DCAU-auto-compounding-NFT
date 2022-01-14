// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev This smart contract is for ERC1155 type NFT maketplace in DCAU protocol
 */

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./libraries/TransferHelper.sol";

import "hardhat/console.sol";

contract DCAUMiscNFTMarket is ReentrancyGuard, Ownable, ERC1155Holder {
    event TokenOnSale(
        address seller,
        address nftContract,
        uint256 nftId,
        uint256 price,
        uint256 quantity,
        uint256 category,
        uint256 saleIndex
    );
    event TokenRemovedFromSale(uint256 saleIndex, uint256 quantity);
    event TokenSold(address buyer, uint256 saleIndex, uint256 _amount);
    event CommissionTakerChanged(address _commissionTaker);
    event NewCategoryAdded(uint256 categoryId, string _categoryName);
    event NewCollectionAdded(address collectionContract, uint256 _category);
    event CollectionRemoved(address collectionContract);
    event RewarderSet(address indexed user, address _rewarder);

    using EnumerableSet for EnumerableSet.AddressSet;
    using Counters for Counters.Counter;

    EnumerableSet.AddressSet private collections;
    mapping(uint256 => string) public categories;
    mapping(address => uint256) public collectionCategory;

    struct SaleNFT {
        uint256 tokenId;
        uint256 category;
        uint128 unitPrice;
        uint128 quantity;
        address seller;
        address tokenContract;
    }
    // SaleNFT[] private saleNFTList;
    mapping(uint256 => SaleNFT) saleNFTList; // id => SaleNFT
    Counters.Counter private saleIds;

    /* ========== VARIABLES ========== */
    address public immutable DCAU_TOKEN;
    address public commissionTaker;
    uint256 public onSaleNftAmount;
    uint256 public categoryLength;
    uint256 public numCollections = 0;

    uint256 public constant BURN_RATE = 200; // 200 - 2%, 10000 - 100%
    uint256 public constant COMMISSION_RATE = 200;
    uint256 public constant NEST_SUPPORTERS_RATE = 100;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    /**
     * @dev this contract will manage to reward NEST_SUPPORTERS fee to supporters
     */
    address public rewarder;

    /* ========== CONSTRUCTOR ========== */
    constructor(
        address _DCAU_TOKEN,
        address _commissionTaker,
        address _rewarder
    ) {
        require(_DCAU_TOKEN != address(0) && _commissionTaker != address(0) && _rewarder != address(0), "ZERO Address value");
        DCAU_TOKEN = _DCAU_TOKEN;
        commissionTaker = _commissionTaker;
        rewarder = _rewarder;
        onSaleNftAmount = 0;
        categories[1] = "Resources";
        categoryLength = 1;
    }

    /* ========== VIEW FUNCTIONS ========== */

    function isWhitelistedCollection(address stakeContract) public view returns (bool) {
        return collections.contains(stakeContract);
    }

    function getWhitelistedCollection(uint256 index) external view returns (address) {
        return collections.at(index);
    }

    function getSaleNFTLength() external view returns (uint256) {
        return saleIds.current();
    }

    function getSale(uint256 index)
        external
        view
        returns (
            address tokenContract,
            uint256 tokenId,
            uint128 unitPrice,
            uint128 quantity,
            address seller,
            uint256 category
        )
    {
        require(index <= saleIds.current(), "Out of array");
        require(saleNFTList[index].seller != address(0), "This sale is no longer active");

        return (
            saleNFTList[index].tokenContract,
            saleNFTList[index].tokenId,
            saleNFTList[index].unitPrice,
            saleNFTList[index].quantity,
            saleNFTList[index].seller,
            saleNFTList[index].category
        );
    }

    /* ========== MARKET FUNCTIONS ========== */
    function saleNFT(
        address _tokenContract,
        uint256 _tokenId,
        uint128 _unitPrice,
        uint128 _quantity
    ) external nonReentrant {
        require(isWhitelistedCollection(_tokenContract), "Collection not whitelisted!");
        require(_unitPrice > 0 && _quantity > 0, "Price cannot be zero");

        uint256 _saleId = saleIds.current();
        IERC1155 nftTokenContract = IERC1155(_tokenContract);

        nftTokenContract.safeTransferFrom(msg.sender, address(this), _tokenId, _quantity, "");

        uint256 _category = collectionCategory[_tokenContract];
        saleNFTList[_saleId] = SaleNFT(_tokenId, _category, _unitPrice, _quantity, msg.sender, _tokenContract);
        onSaleNftAmount = onSaleNftAmount + 1;

        saleIds.increment();
        emit TokenOnSale(msg.sender, _tokenContract, _tokenId, _unitPrice, _quantity, _category, _saleId);
    }

    function removeNFT(uint256 index, uint256 quantity) external nonReentrant {
        require(saleIds.current() >= index, "Out of array length");

        SaleNFT storage _saleNFT = saleNFTList[index];
        IERC1155 nftTokenContract = IERC1155(_saleNFT.tokenContract);
        require(_saleNFT.seller == msg.sender, "You must be the seller of this NFT");
        require(_saleNFT.quantity >= quantity, "Out of stock");
        nftTokenContract.safeTransferFrom(address(this), msg.sender, _saleNFT.tokenId, quantity, "");

        _saleNFT.quantity = uint128(uint256(_saleNFT.quantity) - quantity);
        if (_saleNFT.quantity == 0) {
            delete saleNFTList[index];
            onSaleNftAmount = onSaleNftAmount - 1;
        }

        emit TokenRemovedFromSale(index, quantity);
    }

    function buyNFT(uint256 index, uint256 _amount) external nonReentrant {
        require(saleIds.current() >= index, "Out of array length");
        require(saleNFTList[index].seller != address(0), "This sale is no longer active");
        require(saleNFTList[index].seller != msg.sender, "Seller is owner");

        SaleNFT storage _saleNFT = saleNFTList[index];
        require(_saleNFT.quantity >= _amount, "Out of stock");
        IERC1155 nftTokenContract = IERC1155(_saleNFT.tokenContract);

        uint256 itemPrice = _saleNFT.unitPrice * _amount;

        uint256 burnAmount = (itemPrice * BURN_RATE) / 10000;
        uint256 commissionAmount = (itemPrice * COMMISSION_RATE) / 10000;
        uint256 nestSptAmount = (itemPrice * NEST_SUPPORTERS_RATE) / 10000;
        uint256 sellerAmount = itemPrice - burnAmount - commissionAmount - nestSptAmount;

        require(sellerAmount > 0, "Seller amount must be bigger than zero");

        if (burnAmount > 0) {
            TransferHelper.safeTransferFrom(DCAU_TOKEN, msg.sender, BURN_ADDRESS, burnAmount);
        }

        if (commissionAmount > 0) {
            TransferHelper.safeTransferFrom(DCAU_TOKEN, msg.sender, commissionTaker, commissionAmount);
        }

        if (nestSptAmount > 0) {
            TransferHelper.safeTransferFrom(DCAU_TOKEN, msg.sender, rewarder, nestSptAmount);
        }

        TransferHelper.safeTransferFrom(DCAU_TOKEN, msg.sender, _saleNFT.seller, sellerAmount);
        nftTokenContract.safeTransferFrom(address(this), msg.sender, _saleNFT.tokenId, _amount, "");

        _saleNFT.quantity = uint128(uint256(_saleNFT.quantity) - _amount);
        if (_saleNFT.quantity == 0) {
            delete saleNFTList[index];
            onSaleNftAmount = onSaleNftAmount - 1;
        }

        emit TokenSold(msg.sender, index, _amount);
    }

    // /* ========== RESTRICTED FUNCTIONS ========== */

    function setCommissionTaker(address _commissionTaker) external onlyOwner {
        require(_commissionTaker != commissionTaker, "New commission taker must be different from old one");
        require(_commissionTaker != address(0), "Commissiontaker cannot be zero address");
        commissionTaker = _commissionTaker;

        emit CommissionTakerChanged(_commissionTaker);
    }

    function addNewCategory(string memory _categoryName) external onlyOwner {
        categories[categoryLength + 1] = _categoryName;
        categoryLength = categoryLength + 1;

        emit NewCategoryAdded(categoryLength, _categoryName);
    }

    function addWhitelistedCollection(address collectionContract, uint256 _category) external onlyOwner {
        require(collectionContract != address(0), "addWhitelistedCollection: collectionContract cannot be the zero address");
        require(isWhitelistedCollection(collectionContract) == false, "addWhitelistedCollection: collection already whitelisted");
        require(_category <= categoryLength, "addWhitelistedCollection: Not listed category");

        collections.add(collectionContract);
        collectionCategory[collectionContract] = _category;

        numCollections = numCollections + 1;

        emit NewCollectionAdded(collectionContract, _category);
    }

    function removeWhitelistedCollection(address collectionContract) external onlyOwner {
        require(isWhitelistedCollection(collectionContract), "removeWhitelistedCollection: collection not whitelisted");

        collections.remove(collectionContract);
        collectionCategory[collectionContract] = 0;

        numCollections = numCollections - 1;

        emit CollectionRemoved(collectionContract);
    }

    function setRewarder(address _rewarder) external onlyOwner {
        rewarder = _rewarder;

        emit RewarderSet(msg.sender, rewarder);
    }
}
