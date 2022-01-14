// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/TransferHelper.sol";

contract DragonNestSupporter is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    event Sold(address indexed buyer, uint256 indexed tokenId);
    event SaleActivated(address indexed user);
    event AddWhitelist(address indexed user, address indexed whitelisted, uint256 whitelistAmount);
    event ItemCostSet(address indexed user, uint256 cost);

    Counters.Counter public TOKEN_IDS;

    Counters.Counter public CURRENT_SALE_ID;

    address public immutable STABLETOKEN;
    address public immutable DEVWALLET;

    uint256 public ITEMCOST;

    mapping(address => bool) public WHITELIST;

    mapping(address => uint256) public WHITELISTED_ADDRESSES_AMOUNT;

    bool private _isSaleActive;

    uint256 public immutable PUBLICSALETIMESTAMP;

    constructor(
        address devWallet,
        address _stableToken,
        uint256 _publicSaleOpenTimestamp
    ) ERC721("Dragon Nest Supporters", "DCNS") {
        require(devWallet != address(0), "must be valid address");
        require(_stableToken != address(0), "must be valid address");
        require(_publicSaleOpenTimestamp > block.timestamp, "must open in the future");

        DEVWALLET = devWallet;
        STABLETOKEN = _stableToken;
        PUBLICSALETIMESTAMP = _publicSaleOpenTimestamp;
    }

    function addWhiteList(address whitelistAddress) external onlyOwner {
        require(WHITELISTED_ADDRESSES_AMOUNT[whitelistAddress] + balanceOf(whitelistAddress) < 2, "already has 2 in allowance");

        WHITELIST[whitelistAddress] = true;
        WHITELISTED_ADDRESSES_AMOUNT[whitelistAddress]++;

        emit AddWhitelist(msg.sender, whitelistAddress, WHITELISTED_ADDRESSES_AMOUNT[whitelistAddress]);
    }

    function activateSale() external onlyOwner {
        require(!_isSaleActive, "sale is already active");
        require(ITEMCOST > 0, "items must have a price to go on sale");

        _isSaleActive = true;

        emit SaleActivated(msg.sender);
    }

    function mintItem(string memory tokenURI) external onlyOwner returns (uint256) {
        require(TOKEN_IDS.current() < 25, "All tokens have been minted");

        TOKEN_IDS.increment();

        uint256 newItemId = TOKEN_IDS.current();
        _mint(address(this), newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }

    function buyDragonNest() external nonReentrant {
        require(balanceOf(_msgSender()) < 2, "Dragon:Forbidden");
        require(_isSaleActive, "sale must be active");
        require(CURRENT_SALE_ID.current() < 25, "all tokens sold");

        if (block.timestamp < PUBLICSALETIMESTAMP) {
            require(WHITELIST[msg.sender], "Not in whitelist");
            require(WHITELISTED_ADDRESSES_AMOUNT[msg.sender] > 0, "must have purchases left");
        }

        CURRENT_SALE_ID.increment();

        TransferHelper.safeTransferFrom(STABLETOKEN, _msgSender(), DEVWALLET, ITEMCOST);

        _safeTransfer(address(this), msg.sender, CURRENT_SALE_ID.current(), "");

        if (block.timestamp < PUBLICSALETIMESTAMP) {
            WHITELISTED_ADDRESSES_AMOUNT[msg.sender]--;
        }

        emit Sold(msg.sender, CURRENT_SALE_ID.current());
    }

    function setItemCost(uint256 _cost) external onlyOwner {
        ITEMCOST = _cost;

        emit ItemCostSet(msg.sender, _cost);
    }
}
