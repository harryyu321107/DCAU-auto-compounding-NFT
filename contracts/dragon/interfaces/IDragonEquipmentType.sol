// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of DragonEquipmentType.
 */
interface IDragonEquipmentType {
    function EQUIPMENT_BODY() external view returns (uint8);

    function EQUIPMENT_FIRST_HAND() external view returns (uint8);

    function EQUIPMENT_SECOND_HAND() external view returns (uint8);

    function EQUIPMENT_TWO_HANDS() external view returns (uint8);

    function EQUIPMENT_LEFT_RING() external view returns (uint8);

    function EQUIPMENT_RIGHT_RING() external view returns (uint8);

    function EQUIPMENT_HEAD() external view returns (uint8);

    function EQUIPMENT_NECK() external view returns (uint8);

    function EQUIPMENT_BACK() external view returns (uint8);

    function EQUIPMENT_SHOULDERS() external view returns (uint8);

    function EQUIPMENT_ARMS() external view returns (uint8);

    function EQUIPMENT_GLOVES() external view returns (uint8);

    function EQUIPMENT_LEGS() external view returns (uint8);

    function EQUIPMENT_FEET() external view returns (uint8);

    function EQUIPMENT_WAIST() external view returns (uint8);

    function EQUIPMENT_UTILITY() external view returns (uint8);
}
