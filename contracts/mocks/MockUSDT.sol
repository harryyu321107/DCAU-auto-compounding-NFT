// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20 {
    uint256 public constant faucetLimit = 500000 * 10**18;

    constructor(
        string memory name,
        string memory symbol,
        uint256 supply
    ) ERC20(name, symbol) {
        _mint(msg.sender, supply);
    }

    function faucetToken(uint256 _amount) external {
        require(_amount <= faucetLimit, "Faucet amount limitation");
        _mint(msg.sender, _amount);
    }
}
