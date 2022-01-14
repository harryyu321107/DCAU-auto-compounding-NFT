// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of DragonEquipmentType.
 */
interface IDragonEquipment {
    function typeOfItem(uint256 _tokenId) external view returns (uint8);

    function damage(uint256 _tokenId, uint256 _damageAmount) external returns (bool);
}
