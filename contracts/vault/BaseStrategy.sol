// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/IUniPair.sol";
import "../interfaces/IUniRouter02.sol";

abstract contract BaseStrategy is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    address public wantAddress;
    address public earnedAddress;

    address public uniRouterAddress;
    address public dcauAddress;
    address public withdrawFeeAddress;
    address public feeAddress;
    address public vaultChefAddress;
    address public govAddress;

    uint256 public lastEarnBlock = block.number;
    uint256 public sharesTotal;

    address public constant buyBackAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public controllerFee = 50;
    uint256 public rewardRate;
    uint256 public buyBackRate = 150;
    uint256 public constant feeMaxTotal = 1000;
    uint256 public constant feeMax = 10000; // 100 = 1%

    uint256 public withdrawFeeFactor = 9900; // 10% withdraw fee, origin: 0% withdraw fee -> withdrawFeeFactor = 10000;
    uint256 public constant withdrawFeeFactorMax = 10000;
    uint256 public constant withdrawFeeFactorLL = 9900;

    uint256 public slippageFactor = 950; // 5% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address[] public earnedToWmaticPath; // for distributeFee, DNGN_WMATIC path
    address[] public earnedToDcauPath; // for buyBack, do we need it?

    bool public HasPanicked = false;

    event SetSettings(
        uint256 _controllerFee,
        uint256 _rewardRate,
        uint256 _buyBackRate,
        uint256 _withdrawFeeFactor,
        uint256 _slippageFactor
    );

    event Panic(address indexed _gov);
    event UnPanic(address indexed _gov);
    event ResetAllowances(address indexed _gov);
    event SetGov(address indexed _oldGov, address indexed _newGov);

    modifier onlyGov() {
        require(msg.sender == govAddress, "!gov");
        _;
    }

    function _vaultDeposit(uint256 _amount) internal virtual;

    function _vaultWithdraw(uint256 _amount) internal virtual;

    function earn() external virtual;

    function totalInUnderlying() public view virtual returns (uint256);

    function wantLockedTotal() public view virtual returns (uint256);

    function _resetAllowances() internal virtual;

    function _revokeAllowances() internal virtual;

    function _emergencyVaultWithdraw() internal virtual;

    function deposit(uint256 _wantAmt) external onlyOwner nonReentrant whenNotPaused returns (uint256) {
        // Call must happen before transfer
        uint256 wantLockedBefore = wantLockedTotal();

        uint256 balanceBefore = IERC20(wantAddress).balanceOf(address(this));
        IERC20(wantAddress).safeTransferFrom(address(msg.sender), address(this), _wantAmt);
        _wantAmt = IERC20(wantAddress).balanceOf(address(this)) - balanceBefore;
        require(_wantAmt > 0, "We only accept amount > 0");

        // Proper deposit amount for tokens with fees, or vaults with deposit fees
        uint256 underlyingAdded = _farm();

        //The share amount is the underlying added amount unless there is shares
        //then the share total is used to calculate the share amount
        uint256 sharesAmount = underlyingAdded;

        if (sharesTotal > 0) {
            sharesAmount = (underlyingAdded * sharesTotal) / wantLockedBefore;
        }

        sharesTotal = sharesTotal + sharesAmount;

        return sharesAmount;
    }

    function _farm() internal returns (uint256) {
        uint256 wantAmt = IERC20(wantAddress).balanceOf(address(this));
        if (wantAmt == 0) return 0;
        uint256 underlyingBefore = totalInUnderlying();
        _vaultDeposit(wantAmt);
        uint256 underlyingAfter = totalInUnderlying();

        return underlyingAfter - underlyingBefore;
    }

    function withdraw(uint256 _wantAmt) external onlyOwner nonReentrant returns (uint256) {
        require(_wantAmt > 0, "_wantAmt is 0");

        uint256 wantLockedBefore = wantLockedTotal();

        uint256 actualBalanceWantAmt = IERC20(wantAddress).balanceOf(address(this));

        // Check if strategy has tokens from panic
        if (_wantAmt > actualBalanceWantAmt) {
            _vaultWithdraw(_wantAmt - actualBalanceWantAmt);
            actualBalanceWantAmt = IERC20(wantAddress).balanceOf(address(this));
        }

        uint256 wantAmtToReceive = _wantAmt;

        if (wantAmtToReceive > actualBalanceWantAmt) {
            wantAmtToReceive = actualBalanceWantAmt;
        }

        uint256 sharesRemoved = (_wantAmt * sharesTotal) / wantLockedBefore;
        if (sharesRemoved > sharesTotal) {
            sharesRemoved = sharesTotal;
        }
        sharesTotal = sharesTotal - sharesRemoved;

        // Withdraw fee
        uint256 withdrawFee = (wantAmtToReceive * (withdrawFeeFactorMax - withdrawFeeFactor)) / withdrawFeeFactorMax;
        if (withdrawFee > 0) {
            IERC20(wantAddress).safeTransfer(withdrawFeeAddress, withdrawFee);
            wantAmtToReceive = wantAmtToReceive - withdrawFee;
        }

        IERC20(wantAddress).safeTransfer(vaultChefAddress, wantAmtToReceive);

        return sharesRemoved;
    }

    // To pay for earn function
    function distributeFees(uint256 _earnedAmt) internal returns (uint256) {
        if (controllerFee > 0) {
            uint256 fee = (_earnedAmt * controllerFee) / feeMax;
            _safeSwapWmatic(fee, earnedToWmaticPath, feeAddress);
            _earnedAmt = _earnedAmt - fee;
        }

        return _earnedAmt;
    }

    function buyBack(uint256 _earnedAmt) internal virtual returns (uint256) {
        if (earnedAddress == dcauAddress) {
            return _earnedAmt;
        }
        if (buyBackRate > 0) {
            uint256 buyBackAmt = (_earnedAmt * buyBackRate) / feeMax;
            if (earnedAddress != dcauAddress) {
                _safeSwap(buyBackAmt, earnedToDcauPath, buyBackAddress);
            }
            _earnedAmt = _earnedAmt - buyBackAmt;
        }

        return _earnedAmt;
    }

    function resetAllowances() external onlyGov {
        _resetAllowances();
        emit ResetAllowances(msg.sender);
    }

    function pause() external onlyGov {
        _pause();
    }

    function panic() external onlyGov {
        HasPanicked = true;

        _pause();
        _revokeAllowances();
        _emergencyVaultWithdraw();
        emit Panic(msg.sender);
    }

    function unpause() external onlyGov {
        require(!HasPanicked, "cannot unpause a panicked strategy");

        _unpause();
        _resetAllowances();
        _farm();
        emit UnPanic(msg.sender);
    }

    function setGov(address _govAddress) external onlyGov {
        govAddress = _govAddress;
        emit SetGov(msg.sender, _govAddress);
    }

    function setSettings(
        uint256 _controllerFee,
        uint256 _rewardRate,
        uint256 _buyBackRate,
        uint256 _withdrawFeeFactor,
        uint256 _slippageFactor
    ) external onlyGov {
        require(_controllerFee + _rewardRate + _buyBackRate <= feeMaxTotal, "Max fee of 10%");
        require(_withdrawFeeFactor >= withdrawFeeFactorLL, "_withdrawFeeFactor too low");
        require(_withdrawFeeFactor <= withdrawFeeFactorMax, "_withdrawFeeFactor too high");
        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");
        controllerFee = _controllerFee;
        rewardRate = _rewardRate;
        buyBackRate = _buyBackRate;
        withdrawFeeFactor = _withdrawFeeFactor;
        slippageFactor = _slippageFactor;

        emit SetSettings(_controllerFee, _rewardRate, _buyBackRate, _withdrawFeeFactor, _slippageFactor);
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        if (_amountIn > 0) {
            uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
            uint256 amountOut = amounts[amounts.length - 1];

            IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amountIn,
                (amountOut * slippageFactor) / 1000,
                _path,
                _to,
                block.timestamp
            );
        }
    }

    function _safeSwapWmatic(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        if (_amountIn > 0) {
            uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
            uint256 amountOut = amounts[amounts.length - 1];

            IUniRouter02(uniRouterAddress).swapExactTokensForAVAXSupportingFeeOnTransferTokens(
                _amountIn,
                (amountOut * slippageFactor) / 1000,
                _path,
                _to,
                block.timestamp
            );
        }
    }
}
