// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IMasterChef {
    function depositMarketFee(uint256 _pid, uint256 _amount) external;
}
