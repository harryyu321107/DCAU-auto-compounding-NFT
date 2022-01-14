// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/**
 * @dev This smart contract is for easy bulk mint of DragonPlayerCharacter or something else
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IDragonEquipment.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract DragonEquipmentBulkMint is Ownable, ERC721Holder {
    constructor() {}

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function bulkMint(
        address _equipment,
        address[] memory _owner,
        uint16[] memory _type,
        uint64[] memory _damage,
        uint64[] memory _defense,
        uint64[] memory _durability,
        uint64[] memory _speed,
        uint64[] memory _endurance,
        uint64[] memory _luck
    ) public onlyOwner {
        uint256 len = _owner.length;
        require(
                len == _type.length &&
                len == _damage.length &&
                len == _defense.length &&
                len == _durability.length &&
                len == _speed.length &&
                len == _endurance.length &&
                len == _luck.length,
            "Not equal params length"
        );
        uint256 ii;
        
        for (ii = 0; ii < len; ii++) {
            uint256 itemId = IDragonEquipment(_equipment).mintNewEquipment(
                _owner[ii],
                _type[ii],
                _damage[ii],
                _defense[ii],
                _durability[ii],
                _speed[ii],
                _endurance[ii],
                _luck[ii]
            );
            IERC721(_equipment).transferFrom(address(this), msg.sender, itemId);
        }
    }

    function transferCharacterOwnerShip(address _character, address _to) external onlyOwner {
        IDragonEquipment(_character).transferOwnership(_to);
    }
}
