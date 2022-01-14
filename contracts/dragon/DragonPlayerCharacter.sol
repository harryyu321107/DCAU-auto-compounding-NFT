// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../libraries/Authorizable.sol";
import "./interfaces/IDragonEquipment.sol";
import "./interfaces/IDragonEquipmentType.sol";

contract DragonPlayerCharacter is ERC721, Authorizable, ReentrancyGuard, ERC721Holder {
    using Counters for Counters.Counter;
    Counters.Counter public tokenIds;

    uint256 public constant START_STAT_POINTS = 15;
    uint256 public constant HEALTH_MULTIPLIER = 100;
    uint64 public constant START_LEVEL = 1;
    uint64 public constant START_EXP = 0;
    uint256 public constant BASE_EXP_TO_LEVEL = 2500;
    uint64 public constant STAT_POINTS_PER_LEVEL = 4;

    address public immutable DRAGON_EQUIPMENT;
    string private _uriUrl;

    /**
     * Dragon stats
     * @dev We think uint64 is enough for displaying stats
     */
    struct CharacterStats {
        uint64 attack;
        uint64 defense;
        uint64 speed;
        uint64 endurance;
        uint64 luck;
        uint64 experience;
        uint64 crafting;
        uint64 gathering;
        uint64 magic;
        uint64 level;
        uint64 currentHealth;
        uint64 totalHealth;
        uint64 statPointsToSpend;
        uint256 created;
        bool isAlive;
    }

    // uint8 public override EQUIPMENT_BODY = 1;
    // uint8 public override EQUIPMENT_FIRST_HAND = 2;
    // uint8 public override EQUIPMENT_SECOND_HAND = 3;
    // uint8 public override EQUIPMENT_TWO_HANDS = 4;
    // uint8 public override EQUIPMENT_LEFT_RING = 5;
    // uint8 public override EQUIPMENT_RIGHT_RING = 6;
    // uint8 public override EQUIPMENT_HEAD = 7;
    // uint8 public override EQUIPMENT_NECK = 8;
    // uint8 public override EQUIPMENT_BACK = 9;
    // uint8 public override EQUIPMENT_SHOULDERS = 10;
    // uint8 public override EQUIPMENT_ARMS = 11;
    // uint8 public override EQUIPMENT_GLOVES = 12;
    // uint8 public override EQUIPMENT_LEGS = 13;
    // uint8 public override EQUIPMENT_FEET = 14;
    // uint8 public override EQUIPMENT_WAIST = 15;
    // uint8 public override EQUIPMENT_UTILITY = 16;

    struct CharacterEquipment {
        uint256 body; // Equipment token ID, should be body type
        uint256 firstHand; // Equipment token ID, should be hand1 type
        uint256 secondHand; // Equipment token ID, should be hand2 type
        uint256 twoHanded; // Equipment token ID, should be both hand type
        uint256 leftRing;
        uint256 rightRing;
        uint256 head;
        uint256 neck;
        uint256 back;
        uint256 shoulders;
        uint256 arms;
        uint256 gloves;
        uint256 legs;
        uint256 feet;
        uint256 waist;
        uint256 utility;
    }

    mapping(uint256 => CharacterStats) private playerStats; // characterId => Dragon
    mapping(uint256 => mapping(uint8 => uint256)) private equippedEquipment; // character => type => equipmentNFT id
    mapping(address => bool) private allowedUtilities;

    event MintPlayerCharacter(address indexed _creator, uint256 indexed _tokenId, CharacterStats _stats);
    event AddUtility(address _utility, address _user);
    event Heal(uint256 indexed _tokenId, address _user);
    event Resurrect(uint256 indexed _tokenId, address _user);
    event AddExperience(uint256 indexed _tokenId, uint256 _experience);
    event LevelUp(uint256 indexed _tokenId, uint256 _newLevel, uint256 _levelUp);

    constructor(address _DRAGON_EQUIPMENT, string memory uriUrl_) ERC721("Dragon Player Character", "DPC") {
        require(_DRAGON_EQUIPMENT != address(0), "Dragon: ZERO_ADDRESS");
        DRAGON_EQUIPMENT = _DRAGON_EQUIPMENT;
        _uriUrl = uriUrl_;
    }

    function _baseURI() internal view override returns (string memory) {
        return _uriUrl;
    }

    function mintCharacter(
        uint256 attack,
        uint256 defense,
        uint256 speed,
        uint256 endurance,
        uint256 crafting,
        uint256 gathering,
        uint256 magic,
        uint256 rank
    ) external onlyOwner nonReentrant returns (uint256) {
        require(
            attack + defense + speed + endurance + crafting + gathering + magic == START_STAT_POINTS,
            "Dragon: Invalid stats"
        );

        uint64 startHealth = uint64(endurance * HEALTH_MULTIPLIER);

        uint256 newItemId = tokenIds.current();

        playerStats[newItemId] = CharacterStats({
            attack: uint64(attack * rank),
            defense: uint64(defense * rank),
            speed: uint64(speed * rank),
            endurance: uint64(endurance * rank),
            luck: 0,
            experience: START_EXP,
            level: START_LEVEL,
            totalHealth: startHealth,
            currentHealth: startHealth,
            statPointsToSpend: 0,
            crafting: uint64(crafting * rank),
            gathering: uint64(gathering * rank),
            magic: uint64(magic * rank),
            created: block.timestamp,
            isAlive: true
        });

        _mint(msg.sender, newItemId);
        tokenIds.increment();

        emit MintPlayerCharacter(msg.sender, newItemId, playerStats[newItemId]);
        return newItemId;
    }

    function addUtility(address utilityAddress) public onlyOwner {
        allowedUtilities[utilityAddress] = true;

        emit AddUtility(utilityAddress, msg.sender);
    }

    function heal(uint256 playerId) public onlyAuthorized {
        playerStats[playerId].currentHealth = playerStats[playerId].totalHealth;

        emit Heal(playerId, msg.sender);
    }

    function resurrect(uint256 playerId) public onlyAuthorized {
        heal(playerId);
        playerStats[playerId].isAlive = true;

        emit Resurrect(playerId, msg.sender);
    }

    function viewPlayerStats(uint256 playerId) external view returns (CharacterStats memory) {
        return playerStats[playerId];
    }

    function viewPlayerEquipment(uint256 playerId) external view returns (CharacterEquipment memory) {
        IDragonEquipmentType _dgEquipType = IDragonEquipmentType(DRAGON_EQUIPMENT);

        return
            CharacterEquipment({
                body: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_BODY()],
                firstHand: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_FIRST_HAND()],
                secondHand: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_SECOND_HAND()],
                twoHanded: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_TWO_HANDS()],
                leftRing: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_LEFT_RING()],
                rightRing: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_RIGHT_RING()],
                head: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_HEAD()],
                neck: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_NECK()],
                back: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_BACK()],
                shoulders: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_SHOULDERS()],
                arms: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_ARMS()],
                gloves: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_GLOVES()],
                legs: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_LEGS()],
                feet: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_FEET()],
                waist: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_WAIST()],
                utility: equippedEquipment[playerId][_dgEquipType.EQUIPMENT_UTILITY()]
            });
    }

    function addExperience(
        uint256 characterId,
        uint256 experienceAmount,
        uint256 levelIncreased
    ) public onlyAuthorized {
        CharacterStats storage character = playerStats[characterId];

        uint256 experienceToNextLevel = character.level * BASE_EXP_TO_LEVEL;
        uint256 newExperience = character.experience + experienceAmount;

        if (newExperience >= experienceToNextLevel) {
            // lev_cur * BASE_EXP_TO_LEVEL + (lev_cur + 1) * BASE_EXP_TO_LEVEL + ... + (lev_cur + levelIncreased) * BASE_EXP_TO_LEVEL <= newExperience
            // <=> BASE_EXP_TO_LEVEL * (levelIncreased + 1) * (2 * lev_cur + levelIncreased) <= 2 * newExperience
            // lev_cur * BASE_EXP_TO_LEVEL + (lev_cur + 1) * BASE_EXP_TO_LEVEL + ... + (lev_cur + levelIncreased + 1) * BASE_EXP_TO_LEVEL > newExperience
            // <=> BASE_EXP_TO_LEVEL * (levelIncreased + 2) * (2 * lev_cur + levelIncreased + 1) > 2 * newExperience
            require(validateLevelUp(character.level, newExperience, levelIncreased), "Dragon: invalid level up");

            uint64 experienceLeftOver = uint64(newExperience - experienceToNextLevel);
            character.experience = experienceLeftOver;
            character.level += uint64(levelIncreased + 1);
            character.statPointsToSpend += uint64((levelIncreased + 1) * STAT_POINTS_PER_LEVEL);

            emit LevelUp(characterId, character.level, levelIncreased + 1);
        } else {
            character.experience = uint64(newExperience);
        }

        emit AddExperience(characterId, experienceAmount);
    }

    function validateLevelUp(
        uint256 _currentLevel,
        uint256 _experience,
        uint256 _levelIncreased
    ) private pure returns (bool) {
        uint256 rightSide = 2 * _experience;
        uint256 leftSide = BASE_EXP_TO_LEVEL * (_levelIncreased + 1) * (2 * _currentLevel + _levelIncreased);
        if (leftSide > rightSide) {
            return false;
        }
        leftSide = BASE_EXP_TO_LEVEL * (_levelIncreased + 2) * (2 * _currentLevel + _levelIncreased + 1);
        if (leftSide <= rightSide) {
            return false;
        }
        return true;
    }

    /**
     * @dev this function is called only in addEquipment function
     */
    function equipSlot(
        uint256 playerId,
        uint256 equippingId,
        uint8 slot
    ) internal {
        // change or add equipment into slot
        if (equippingId > 0 && equippingId != equippedEquipment[playerId][slot]) {
            if (equippedEquipment[playerId][slot] > 0) {
                IERC721(DRAGON_EQUIPMENT).transferFrom(address(this), msg.sender, equippedEquipment[playerId][slot]);
            }

            IERC721(DRAGON_EQUIPMENT).transferFrom(msg.sender, address(this), equippingId);

            equippedEquipment[playerId][slot] = equippingId;
            // remove equipment in the slot
        } else if (equippedEquipment[playerId][slot] > 0) {
            IERC721(DRAGON_EQUIPMENT).transferFrom(address(this), msg.sender, equippedEquipment[playerId][slot]);
            equippedEquipment[playerId][slot] = 0;
        }
    }

    function updateEquipment(
        uint256 _playerId,
        uint256[] calldata _equipments, // should be length 16
        address _utilityAddress
    ) external nonReentrant {
        require(ownerOf(_playerId) == msg.sender, "Dragon: Forbidden");
        require(_equipments.length == 16, "Dragon: Equipments should be 16");
        require(_validateEquipment(_equipments, _utilityAddress), "Dragon: Invalid item combination");

        IDragonEquipmentType _dgEquipType = IDragonEquipmentType(DRAGON_EQUIPMENT);

        equipSlot(_playerId, _equipments[0], _dgEquipType.EQUIPMENT_BODY());
        equipSlot(_playerId, _equipments[1], _dgEquipType.EQUIPMENT_FIRST_HAND());
        equipSlot(_playerId, _equipments[2], _dgEquipType.EQUIPMENT_SECOND_HAND());
        equipSlot(_playerId, _equipments[3], _dgEquipType.EQUIPMENT_TWO_HANDS());
        equipSlot(_playerId, _equipments[4], _dgEquipType.EQUIPMENT_LEFT_RING());
        equipSlot(_playerId, _equipments[5], _dgEquipType.EQUIPMENT_RIGHT_RING());
        equipSlot(_playerId, _equipments[6], _dgEquipType.EQUIPMENT_HEAD());
        equipSlot(_playerId, _equipments[7], _dgEquipType.EQUIPMENT_NECK());
        equipSlot(_playerId, _equipments[8], _dgEquipType.EQUIPMENT_BACK());
        equipSlot(_playerId, _equipments[9], _dgEquipType.EQUIPMENT_SHOULDERS());
        equipSlot(_playerId, _equipments[10], _dgEquipType.EQUIPMENT_ARMS());
        equipSlot(_playerId, _equipments[11], _dgEquipType.EQUIPMENT_GLOVES());
        equipSlot(_playerId, _equipments[12], _dgEquipType.EQUIPMENT_LEGS());
        equipSlot(_playerId, _equipments[13], _dgEquipType.EQUIPMENT_FEET());
        equipSlot(_playerId, _equipments[14], _dgEquipType.EQUIPMENT_WAIST());

        // TODO check this logic
        if (_equipments[15] > 0 && _equipments[15] != equippedEquipment[_playerId][_dgEquipType.EQUIPMENT_UTILITY()]) {
            if (equippedEquipment[_playerId][_dgEquipType.EQUIPMENT_UTILITY()] > 0) {
                IERC721(_utilityAddress).transferFrom(
                    address(this),
                    msg.sender,
                    equippedEquipment[_playerId][_dgEquipType.EQUIPMENT_UTILITY()]
                );
            }

            IERC721(_utilityAddress).transferFrom(msg.sender, address(this), _equipments[15]);

            equippedEquipment[_playerId][_dgEquipType.EQUIPMENT_UTILITY()] = _equipments[15];
        } else if (equippedEquipment[_playerId][_dgEquipType.EQUIPMENT_UTILITY()] > 0) {
            IERC721(_utilityAddress).transferFrom(
                address(this),
                msg.sender,
                equippedEquipment[_playerId][_dgEquipType.EQUIPMENT_UTILITY()]
            );
            equippedEquipment[_playerId][_dgEquipType.EQUIPMENT_UTILITY()] = 0;
        }
    }

    function _validateEquipment(uint256[] calldata _equipments, address _utilityAddress) private view returns (bool) {
        IDragonEquipment _dgEquip = IDragonEquipment(DRAGON_EQUIPMENT);
        IDragonEquipmentType _dgEquipType = IDragonEquipmentType(DRAGON_EQUIPMENT);

        // TODO we should check the case when player hold first handed item in second hand
        // Is there item in first hand, too?
        // Can item in the first hand be the same to the item in the second hand?
        if (
            _dgEquip.typeOfItem(_equipments[0]) != _dgEquipType.EQUIPMENT_BODY() ||
            _dgEquip.typeOfItem(_equipments[1]) != _dgEquipType.EQUIPMENT_FIRST_HAND() ||
            (_dgEquip.typeOfItem(_equipments[2]) != _dgEquipType.EQUIPMENT_FIRST_HAND() &&
                _dgEquip.typeOfItem(_equipments[2]) != _dgEquipType.EQUIPMENT_SECOND_HAND()) ||
            _dgEquip.typeOfItem(_equipments[3]) != _dgEquipType.EQUIPMENT_TWO_HANDS() ||
            _dgEquip.typeOfItem(_equipments[4]) != _dgEquipType.EQUIPMENT_LEFT_RING() ||
            _dgEquip.typeOfItem(_equipments[5]) != _dgEquipType.EQUIPMENT_RIGHT_RING() ||
            _dgEquip.typeOfItem(_equipments[6]) != _dgEquipType.EQUIPMENT_HEAD() ||
            _dgEquip.typeOfItem(_equipments[7]) != _dgEquipType.EQUIPMENT_NECK() ||
            _dgEquip.typeOfItem(_equipments[8]) != _dgEquipType.EQUIPMENT_BACK() ||
            _dgEquip.typeOfItem(_equipments[9]) != _dgEquipType.EQUIPMENT_SHOULDERS() ||
            _dgEquip.typeOfItem(_equipments[10]) != _dgEquipType.EQUIPMENT_ARMS() ||
            _dgEquip.typeOfItem(_equipments[11]) != _dgEquipType.EQUIPMENT_GLOVES() ||
            _dgEquip.typeOfItem(_equipments[12]) != _dgEquipType.EQUIPMENT_LEGS() ||
            _dgEquip.typeOfItem(_equipments[13]) != _dgEquipType.EQUIPMENT_FEET() ||
            _dgEquip.typeOfItem(_equipments[14]) != _dgEquipType.EQUIPMENT_WAIST()
        ) {
            return false;
        }

        // Both handed item can not be equiped with any one handed weapon
        if ((_equipments[1] != 0 || _equipments[2] != 0) && _equipments[3] != 0) {
            return false;
        }

        if (!allowedUtilities[_utilityAddress]) {
            return false;
        }

        return true;
    }
}
