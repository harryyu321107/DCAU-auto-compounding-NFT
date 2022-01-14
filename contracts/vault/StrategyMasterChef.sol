// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * This strategy is for the single asset in MasterChef
 */

import "./interfaces/IMasterChef.sol";
import "./BaseStrategy.sol";

contract StrategyMasterChef is BaseStrategy {
    using SafeERC20 for IERC20;

    address public masterchefAddress;
    uint256 public pid; // MasterChef Pool id

    constructor(
        address[] memory _initialWalletPath,
        address _vaultChefAddress,
        address _masterchefAddress,
        address _uniRouterAddress,
        uint256 _pid,
        address _wantAddress, // the token which we want to put in pool
        address _earnedAddress,
        address[] memory _earnedToWmaticPath
    ) {
        require(_initialWalletPath.length == 3, "Parameter _initialWalletPath length shoud be 3");
        require(
            _initialWalletPath[0] != address(0) && _initialWalletPath[1] != address(0) && _initialWalletPath[2] != address(0),
            "Any of _initialWalletPath should not be ZERO"
        );
        require(
            _wantAddress != address(0) && _earnedAddress != address(0),
            "Want token or earned token should not be ZERO address"
        );
        require(_wantAddress != _earnedAddress, "Want token should not be equal to earned token");
        govAddress = msg.sender;
        dcauAddress = _initialWalletPath[0];
        withdrawFeeAddress = _initialWalletPath[1];
        feeAddress = _initialWalletPath[2];
        vaultChefAddress = _vaultChefAddress;
        masterchefAddress = _masterchefAddress;
        uniRouterAddress = _uniRouterAddress;

        wantAddress = _wantAddress;

        pid = _pid;
        earnedAddress = _earnedAddress;

        earnedToWmaticPath = _earnedToWmaticPath;

        transferOwnership(vaultChefAddress);
        _resetAllowances();
    }

    function earn() external override nonReentrant whenNotPaused onlyGov {
        // Harvest farm tokens
        _vaultHarvest();

        // Converts farm tokens into want tokens
        uint256 earnedAmt = IERC20(earnedAddress).balanceOf(address(this));

        if (earnedAmt > 0) {
            earnedAmt = distributeFees(earnedAmt);
            earnedAmt = buyBack(earnedAmt);

            if (earnedAddress != wantAddress) {
                // Swap half earned to wantAddress
                address[] memory path = new address[](2);
                path[0] = earnedAddress;
                path[1] = wantAddress;
                _safeSwap(earnedAmt, path, address(this));
            }
            lastEarnBlock = block.number;
            _farm();
        }
    }

    function _vaultDeposit(uint256 _amount) internal override {
        IMasterchef(masterchefAddress).deposit(pid, _amount);
    }

    function _vaultWithdraw(uint256 _amount) internal override {
        IMasterchef(masterchefAddress).withdraw(pid, _amount);
    }

    function _vaultHarvest() internal {
        IMasterchef(masterchefAddress).withdraw(pid, 0);
    }

    function totalInUnderlying() public view override returns (uint256) {
        (uint256 amount, ) = IMasterchef(masterchefAddress).userInfo(pid, address(this));
        return amount;
    }

    function wantLockedTotal() public view override returns (uint256) {
        return IERC20(wantAddress).balanceOf(address(this)) + totalInUnderlying();
    }

    function _resetAllowances() internal override {
        IERC20(wantAddress).safeApprove(masterchefAddress, uint256(0));
        IERC20(wantAddress).safeIncreaseAllowance(masterchefAddress, type(uint256).max);

        IERC20(earnedAddress).safeApprove(uniRouterAddress, uint256(0));
        IERC20(earnedAddress).safeIncreaseAllowance(uniRouterAddress, type(uint256).max);
    }

    function _revokeAllowances() internal override {
        IERC20(wantAddress).safeApprove(masterchefAddress, uint256(0));

        IERC20(earnedAddress).safeApprove(uniRouterAddress, uint256(0));
    }

    function _emergencyVaultWithdraw() internal override {
        IMasterchef(masterchefAddress).emergencyWithdraw(pid);
    }
}
