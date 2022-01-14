// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/Authorizable.sol";
import "./DragonEquipmentType.sol";
import "../libraries/DCAULibrary.sol";

// import "./interfaces/IDragonEquipment.sol";

contract DragonEquipment is ERC721, Ownable, Authorizable, ReentrancyGuard, DragonEquipmentType {
    using Counters for Counters.Counter;

    Counters.Counter public tokenIds;

    string private _uriUrl;

    mapping(uint256 => uint16) private _itemType;
    mapping(uint256 => EquipmentStats) public equipmentStats;

    struct EquipmentStats {
        uint64 damage;
        uint64 defense;
        uint64 currentDurability;
        uint64 maxDurability;
        uint64 speed;
        uint64 endurance;
        uint64 luck;
    }

    event EquipmentCreated(
        address indexed _creator,
        uint16 indexed _type,
        uint256 indexed _tokenId,
        address _owner,
        EquipmentStats _stats
    );

    /**
     * @dev constructor param uriUrl should be ennded with '/'
     */
    constructor(string memory uriUrl) ERC721("Dragon Equipment", "DCEQUIP") {
        _uriUrl = uriUrl;
    }

    function _baseURI() internal view override returns (string memory) {
        return _uriUrl;
    }

    function createURIString(uint256 tokenId) internal view returns (string memory) {
        return string(abi.encodePacked(_uriUrl, DCAULibrary.uint2str(tokenId)));
    }

    function typeOfItem(uint256 _tokenId) public view returns (uint16) {
        return _itemType[_tokenId];
    }

    function mintNewEquipment(
        address _owner,
        uint16 _type,
        uint64 _damage,
        uint64 _defense,
        uint64 _durability,
        uint64 _speed,
        uint64 _endurance,
        uint64 _luck
    ) external onlyAuthorized nonReentrant returns (uint256) {
        require(validateType(_type), "Dragon: Invalid equipment type");
        // We increment token id before minting it
        // because in DragonPlayerContract equipment id is 0 means that player has no item
        tokenIds.increment();
        uint256 newItemId = tokenIds.current();

        _mint(_owner, newItemId);

        _itemType[newItemId] = _type;

        equipmentStats[newItemId] = EquipmentStats({
            damage: _damage,
            defense: _defense,
            currentDurability: _durability,
            maxDurability: _durability,
            speed: _speed,
            endurance: _endurance,
            luck: _luck
        });

        emit EquipmentCreated(msg.sender, _type, newItemId, _owner, equipmentStats[newItemId]);

        return newItemId;
    }

    function damage(uint256 _tokenId, uint256 _damageAmount) external onlyAuthorized nonReentrant returns (bool) {
        uint256 currentDurability = uint256(equipmentStats[_tokenId].currentDurability);
        if (currentDurability <= _damageAmount) {
            _burn(_tokenId);
            return true;
        }

        equipmentStats[_tokenId].currentDurability = uint64(currentDurability - _damageAmount);
        return false;
    }
}
