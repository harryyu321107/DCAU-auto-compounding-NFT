// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract MockERC721 is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(string memory _uri_) ERC721("Mock Tiny Dragon", "MTINYDRAGON") {
        for (uint256 ii = 0; ii < 16; ii++) {
            _tokenIds.increment();

            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);

            _setTokenURI(newItemId, _uri_);
        }
    }
}
