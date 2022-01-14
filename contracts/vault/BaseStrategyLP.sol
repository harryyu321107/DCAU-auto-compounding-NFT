// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BaseStrategy.sol";

abstract contract BaseStrategyLP is BaseStrategy {
    using SafeERC20 for IERC20;

    address public token0Address;
    address public token1Address;

    function convertDustToEarned() external nonReentrant whenNotPaused {
        // Converts dust tokens into earned tokens, which will be reinvested on the next earn().

        // Converts token0 dust (if any) to earned tokens
        uint256 token0Amt = IERC20(token0Address).balanceOf(address(this));
        if (token0Amt > 0 && token0Address != earnedAddress) {
            // Swap all dust tokens to earned tokens
            address[] memory _token0ToEarnedPath = new address[](2);
            _token0ToEarnedPath[0] = token0Address;
            _token0ToEarnedPath[1] = earnedAddress;

            _safeSwap(token0Amt, _token0ToEarnedPath, address(this));
        }

        // Converts token1 dust (if any) to earned tokens
        uint256 token1Amt = IERC20(token1Address).balanceOf(address(this));
        if (token1Amt > 0 && token1Address != earnedAddress) {
            // Swap all dust tokens to earned tokens
            address[] memory _token1ToEarnedPath = new address[](2);
            _token1ToEarnedPath[0] = token1Address;
            _token1ToEarnedPath[1] = earnedAddress;

            _safeSwap(token1Amt, _token1ToEarnedPath, address(this));
        }
    }
}
