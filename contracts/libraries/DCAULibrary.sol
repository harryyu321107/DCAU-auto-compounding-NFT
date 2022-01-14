// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

// from uniswap SDK
// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library DCAULibrary {
    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + (j % 10)));
            j /= 10;
        }
        str = string(bstr);
    }
}
