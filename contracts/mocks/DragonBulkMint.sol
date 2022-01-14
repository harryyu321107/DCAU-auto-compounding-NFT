// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/**
 * @dev This smart contract is for easy bulk mint of DragonPlayerCharacter or something else
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IDragonPlayerCharacter.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract DragonBulkMint is Ownable, ERC721Holder {
    constructor() {}

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function bulkMint(
        address _character,
        uint256[] memory attack,
        uint256[] memory defense,
        uint256[] memory speed,
        uint256[] memory endurance,
        uint256[] memory crafting,
        uint256[] memory gathering,
        uint256[] memory magic,
        uint256[] memory rank
    ) public onlyOwner {
        require(
                attack.length == defense.length &&
                attack.length == speed.length &&
                attack.length == endurance.length &&
                endurance.length == crafting.length &&
                crafting.length == gathering.length &&
                gathering.length == magic.length &&
                magic.length == rank.length,
            "Not equal params length"
        );
        uint256 ii;
        uint256 len = attack.length;
        for (ii = 0; ii < len; ii++) {
            uint256 itemId = IDragonPlayerCharacter(_character).mintCharacter(
                attack[ii],
                defense[ii],
                speed[ii],
                endurance[ii],
                crafting[ii],
                gathering[ii],
                magic[ii],
                rank[ii]
            );
            IERC721(_character).transferFrom(address(this), msg.sender, itemId);
        }
    }

    function transferCharacterOwnerShip(address _character, address _to) external onlyOwner {
        IDragonPlayerCharacter(_character).transferOwnership(_to);
    }
}
