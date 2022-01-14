// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of DragonPlayerCharacter.
 */
interface IDragonPlayerCharacter {
    function mintCharacter(
        uint256 attack,
        uint256 defense,
        uint256 speed,
        uint256 endurance,
        uint256 crafting,
        uint256 gathering,
        uint256 magic,
        uint256 rank
    ) external returns (uint256);

    function transferOwnership(address _to) external;
}
