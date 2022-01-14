// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of DragonPlayerCharacter.
 */
interface IDragonEquipment {
    function mintNewEquipment(
        address _owner,
        uint16 _type,
        uint64 _damage,
        uint64 _defense,
        uint64 _durability,
        uint64 _speed,
        uint64 _endurance,
        uint64 _luck
    ) external returns (uint256);

    function transferOwnership(address _to) external;
}
