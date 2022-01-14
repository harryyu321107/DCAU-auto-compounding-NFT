// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev This contract includes dragon equipment types values and
 * validate equipment type function.
 */

import "./interfaces/IDragonEquipmentType.sol";

contract DragonEquipmentType is IDragonEquipmentType {
    // Equipment Types constants
    // Please make sure type = 0 means no equipment
    uint8 public override EQUIPMENT_BODY = 1;
    uint8 public override EQUIPMENT_FIRST_HAND = 2;
    uint8 public override EQUIPMENT_SECOND_HAND = 3;
    uint8 public override EQUIPMENT_TWO_HANDS = 4;
    uint8 public override EQUIPMENT_LEFT_RING = 5;
    uint8 public override EQUIPMENT_RIGHT_RING = 6;
    uint8 public override EQUIPMENT_HEAD = 7;
    uint8 public override EQUIPMENT_NECK = 8;
    uint8 public override EQUIPMENT_BACK = 9;
    uint8 public override EQUIPMENT_SHOULDERS = 10;
    uint8 public override EQUIPMENT_ARMS = 11;
    uint8 public override EQUIPMENT_GLOVES = 12;
    uint8 public override EQUIPMENT_LEGS = 13;
    uint8 public override EQUIPMENT_FEET = 14;
    uint8 public override EQUIPMENT_WAIST = 15;
    uint8 public override EQUIPMENT_UTILITY = 16;

    constructor() {}

    function validateType(uint256 _type) public pure virtual returns (bool) {
        if (_type == 0 || _type > 16) {
            return false;
        }
        return true;
    }
}
