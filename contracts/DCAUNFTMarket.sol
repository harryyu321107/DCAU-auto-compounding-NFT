// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./libraries/TransferHelper.sol";
import "./interfaces/IMasterChef.sol";

contract DCAUNFTMarket is ReentrancyGuard, Ownable, ERC721Holder {
    event TokenOnSale(address seller, address nftContract, uint256 nftId, uint256 price, uint256 category, uint256 saleIndex);
    event TokenRemovedFromSale(uint256 saleIndex);
    event TokenSold(address buyer, uint256 saleIndex);
    event CommissionTakerChanged(address _commissionTaker);
    event NewCategoryAdded(uint256 categoryId, string _categoryName);
    event NewCollectionAdded(address collectionContract, uint256 _category);
    event CollectionRemoved(address collectionContract);
    event MasterchefSet(address indexed user, address masterchef);

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using Counters for Counters.Counter;

    EnumerableSet.AddressSet private collections;
    mapping(uint256 => string) public categories;
    mapping(address => uint256) public collectionCategory;

    struct SaleNFT {
        uint256 tokenId;
        uint256 price;
        address seller;
        uint256 category;
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
    address public MASTER_CHEF;
    uint256 public immutable dcauPoolId;

    /* ========== CONSTRUCTOR ========== */
    constructor(
        address _DCAU_TOKEN,
        address _commissionTaker,
        uint256 _pid
    ) {
        DCAU_TOKEN = _DCAU_TOKEN;
        commissionTaker = _commissionTaker;
        onSaleNftAmount = 0;
        categories[1] = "Characters";
        categories[2] = "Equipment";
        categories[3] = "Utility";
        categories[4] = "Resources";
        categories[5] = "Tiny Dragons";
        categoryLength = 5;
        dcauPoolId = _pid;
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
            uint256 price,
            address seller,
            uint256 category
        )
    {
        require(index <= saleIds.current(), "Out of array");
        require(saleNFTList[index].seller != address(0), "This sale is no longer active");

        return (
            saleNFTList[index].tokenContract,
            saleNFTList[index].tokenId,
            saleNFTList[index].price,
            saleNFTList[index].seller,
            saleNFTList[index].category
        );
    }

    /* ========== MARKET FUNCTIONS ========== */
    function saleNFT(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        require(isWhitelistedCollection(_tokenContract), "Collection not whitelisted!");
        require(_price > 0, "Price cannot be zero");

        uint256 _saleId = saleIds.current();
        IERC721 nftTokenContract = IERC721(_tokenContract);

        nftTokenContract.transferFrom(msg.sender, address(this), _tokenId);

        uint256 _category = collectionCategory[_tokenContract];
        saleNFTList[_saleId] = SaleNFT(_tokenId, _price, msg.sender, _category, _tokenContract);
        onSaleNftAmount = onSaleNftAmount.add(1);

        saleIds.increment();
        emit TokenOnSale(msg.sender, _tokenContract, _tokenId, _price, _category, _saleId);
    }

    function removeNFT(uint256 index) external nonReentrant {
        require(saleIds.current() >= index, "Out of array length");

        IERC721 nftTokenContract = IERC721(saleNFTList[index].tokenContract);
        require(saleNFTList[index].seller == msg.sender, "You must be the seller of this NFT");
        nftTokenContract.transferFrom(address(this), msg.sender, saleNFTList[index].tokenId);

        delete saleNFTList[index];
        onSaleNftAmount = onSaleNftAmount.sub(1);

        emit TokenRemovedFromSale(index);
    }

    function buyNFT(uint256 index) external nonReentrant {
        require(saleIds.current() >= index, "Out of array length");
        require(saleNFTList[index].seller != address(0), "This sale is no longer active");

        SaleNFT memory onSaleNft = saleNFTList[index];
        IERC721 nftTokenContract = IERC721(onSaleNft.tokenContract);

        uint256 burnAmount = onSaleNft.price.mul(BURN_RATE).div(10000);
        uint256 commissionAmount = onSaleNft.price.mul(COMMISSION_RATE).div(10000);
        uint256 nestSptAmount = onSaleNft.price.mul(NEST_SUPPORTERS_RATE).div(10000);
        uint256 sellerAmount = onSaleNft.price.sub(burnAmount).sub(commissionAmount).sub(nestSptAmount);

        require(sellerAmount > 0, "Seller amount must be bigger than zero");

        if (burnAmount > 0) {
            TransferHelper.safeTransferFrom(DCAU_TOKEN, msg.sender, BURN_ADDRESS, burnAmount);
        }

        if (commissionAmount > 0) {
            TransferHelper.safeTransferFrom(DCAU_TOKEN, msg.sender, commissionTaker, commissionAmount);
        }

        if (nestSptAmount > 0) {
            TransferHelper.safeTransferFrom(DCAU_TOKEN, msg.sender, address(this), nestSptAmount);
            TransferHelper.safeApprove(DCAU_TOKEN, MASTER_CHEF, nestSptAmount);
            // bytes4(keccak256(bytes('depositMarketFee(uint256,uint256)')));
            // (bool success, ) = MASTER_CHEF.call(abi.encodeWithSelector(0xb27768d9, dcauPoolId, nestSptAmount));
            // require(success, "Deposit nest supporters fee failed");
            IMasterChef(MASTER_CHEF).depositMarketFee(dcauPoolId, nestSptAmount);
        }

        TransferHelper.safeTransferFrom(DCAU_TOKEN, msg.sender, onSaleNft.seller, sellerAmount);

        nftTokenContract.transferFrom(address(this), msg.sender, onSaleNft.tokenId);

        delete saleNFTList[index];
        onSaleNftAmount = onSaleNftAmount.sub(1);

        emit TokenSold(msg.sender, index);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

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

        numCollections = numCollections.add(1);

        emit NewCollectionAdded(collectionContract, _category);
    }

    function removeWhitelistedCollection(address collectionContract) external onlyOwner {
        require(isWhitelistedCollection(collectionContract), "removeWhitelistedCollection: collection not whitelisted");

        collections.remove(collectionContract);
        collectionCategory[collectionContract] = 0;

        numCollections = numCollections.sub(1);

        emit CollectionRemoved(collectionContract);
    }

    function setMasterchef(address masterchef) external onlyOwner {
        MASTER_CHEF = masterchef;

        emit MasterchefSet(msg.sender, masterchef);
    }
}
