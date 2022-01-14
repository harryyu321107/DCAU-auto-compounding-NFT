// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IDCAU.sol";

// MasterChef is the master of DCAU(Dragon Crypto Aurum). He can make DCAU and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once DCAU is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is ERC721Holder, Ownable, ReentrancyGuard {
    event AddPool(uint256 indexed pid, address lpToken, uint256 allocPoint, uint256 depositFeeBP);
    event SetPool(uint256 indexed pid, address lpToken, uint256 allocPoint, uint256 depositFeeBP);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetFeeAddress(address indexed user, address indexed newAddress);
    event UpdateStartBlock(uint256 newStartBlock);
    event SetDCAUPerSecond(uint256 amount);
    event SetEmissionEndTime(uint256 emissionEndTime);
    event DragonNestStaked(address indexed user, uint256 indexed tokenId);
    event DragonNestWithdrawn(address indexed user, uint256 indexed tokenId);
    event MarketDCAUDeposited(address indexed user, uint256 indexed pid, uint256 amount);

    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of DCAUs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accDCAUPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accDCAUPerShare` (and `lastRewardTime`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. DCAUs to distribute per block. 100 - 1point
        uint256 lastRewardTime; // Last block timestamp that DCAUs distribution occurs.
        uint256 accDCAUPerShare; // Accumulated DCAUs per share, times 1e12. See below.
        uint16 depositFeeBP; // Deposit fee in basis points 10000 - 100%
        uint256 lpSupply;
    }

    struct PoolDragonNestInfo {
        uint256 accDepFeePerShare; // Accumulated LP token(from deposit fee) per share, times 1e12. See below.
        uint256 pendingDepFee; // pending deposit fee for the reward for the Dragon Nest Supporters
    }

    mapping(uint256 => PoolDragonNestInfo) public poolDragonNestInfo; // poolId => poolDragonNestInfo
    mapping(uint256 => mapping(uint256 => uint256)) public dragonNestInfo; // poolId => (nestId => rewardDebt), nestId: NFT tokenId
    mapping(uint256 => address) nestSupporters; // tokenId => nest supporter;
    uint256 public nestSupportersLength;

    uint256 public constant DCAU_MAX_SUPPLY = 155000 * (10**18);

    uint256 public constant MAX_EMISSION_RATE = 1 * (10**18);

    // The Dragon Cyrpto AU TOKEN!
    address public immutable DCAU;
    uint256 public dcauPerSecond;
    address public immutable DRAGON_NEST_SUPPORTER;
    // Deposit Fee address
    address public immutable FEEADDRESS;
    address public immutable GAMEADDRESS;
    address public immutable NFT_MARKET;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The time when Dragon mining starts.
    uint256 public startTime;
    // The time when Dragon mining ends.
    uint256 public emissionEndTime = type(uint256).max;

    address public immutable DEVADDRESS;

    constructor(
        address _DCAU,
        address _DRAGON_NEST_SUPPORTER,
        address _gameAddress,
        address _feeAddress,
        uint256 _startTime,
        uint256 _dcauPerSecond,
        address _devAddress,
        address _NFT_MARKET
    ) {
        require(_DCAU != address(0), "must be valid address");
        require(_DRAGON_NEST_SUPPORTER != address(0), "must be valid address");
        require(_gameAddress != address(0), "must be valid address");
        require(_feeAddress != address(0), "must be valid address");
        require(_startTime > block.timestamp, "must start in the future");
        require(_dcauPerSecond <= MAX_EMISSION_RATE, "emission rate too high");
        require(_devAddress != address(0), "must be valid address");
        require(_NFT_MARKET != address(0), "must be valid address");

        DCAU = _DCAU;
        DRAGON_NEST_SUPPORTER = _DRAGON_NEST_SUPPORTER;
        FEEADDRESS = _feeAddress;
        startTime = _startTime;
        dcauPerSecond = _dcauPerSecond;
        DEVADDRESS = _devAddress;
        GAMEADDRESS = _gameAddress;
        NFT_MARKET = _NFT_MARKET;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    mapping(IERC20 => bool) public poolExistence;
    modifier nonDuplicated(IERC20 _lpToken) {
        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        uint16 _depositFeeBP,
        bool _withUpdate
    ) external onlyOwner nonDuplicated(_lpToken) {
        require(poolInfo.length < 20, "too many pools");

        // Make sure the provided token is ERC20
        _lpToken.balanceOf(address(this));

        require(_depositFeeBP <= 401, "add: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardTime = block.timestamp > startTime ? block.timestamp : startTime;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolExistence[_lpToken] = true;

        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardTime: lastRewardTime,
                accDCAUPerShare: 0,
                depositFeeBP: _depositFeeBP,
                lpSupply: 0
            })
        );

        emit AddPool(poolInfo.length - 1, address(_lpToken), _allocPoint, _depositFeeBP);
    }

    // Update the given pool's DCAU allocation point and deposit fee. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        bool _withUpdate
    ) external onlyOwner {
        require(_depositFeeBP <= 401, "set: invalid deposit fee basis points");
        require(_pid < poolInfo.length, "Dragon: Non-existent pool");

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;

        emit SetPool(_pid, address(poolInfo[_pid].lpToken), _allocPoint, _depositFeeBP);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        // As we set the multiplier to 0 here after emissionEndTime
        // deposits aren't blocked after farming ends.
        // reward every 1 seconds
        if (_from > emissionEndTime) return 0;
        if (_to > emissionEndTime) return (emissionEndTime - _from);
        else return (_to - _from);
    }

    // View function to see pending DCAUs on frontend.
    function pendingDcau(uint256 _pid, address _user) external view returns (uint256) {
        require(_pid < poolInfo.length, "Dragon: Non-existent pool");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accDcauPerShare = pool.accDCAUPerShare;

        if (block.timestamp > pool.lastRewardTime && pool.lpSupply != 0 && totalAllocPoint > 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
            uint256 dcauReward = (multiplier * dcauPerSecond * pool.allocPoint) / totalAllocPoint;

            uint256 dcauTotalSupply = IERC20(DCAU).totalSupply();

            uint256 gameDevDcauReward = dcauReward / 15;

            // This shouldn't happen, but just in case we stop rewards.
            if (dcauTotalSupply >= DCAU_MAX_SUPPLY) {
                dcauReward = 0;
            } else if ((dcauTotalSupply + dcauReward + gameDevDcauReward) > DCAU_MAX_SUPPLY) {
                uint256 dcauSupplyRemaining = DCAU_MAX_SUPPLY - dcauTotalSupply;
                dcauReward = (dcauSupplyRemaining * 15) / 16;
            }

            accDcauPerShare = accDcauPerShare + ((dcauReward * 1e12) / pool.lpSupply);
        }

        return ((user.amount * accDcauPerShare) / 1e12) - user.rewardDebt;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        require(_pid < poolInfo.length, "Dragon: Non-existent pool");

        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }

        if (pool.lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
        uint256 dcauReward = (multiplier * dcauPerSecond * pool.allocPoint) / totalAllocPoint;
        uint256 dcauTotalSupply = IERC20(DCAU).totalSupply();

        uint256 gameDevDcauReward = dcauReward / 15;

        // This shouldn't happen, but just in case we stop rewards.
        if (dcauTotalSupply >= DCAU_MAX_SUPPLY) {
            dcauReward = 0;
            gameDevDcauReward = 0;
        } else if ((dcauTotalSupply + dcauReward + gameDevDcauReward) > DCAU_MAX_SUPPLY) {
            uint256 dcauSupplyRemaining = DCAU_MAX_SUPPLY - dcauTotalSupply;
            dcauReward = (dcauSupplyRemaining * 15) / 16;
            gameDevDcauReward = dcauSupplyRemaining - dcauReward;
        }

        if (dcauReward > 0) {
            IDCAU(DCAU).mint(address(this), dcauReward);
        }

        if (gameDevDcauReward > 0) {
            uint256 devReward = (gameDevDcauReward * 1) / 3;
            uint256 gameReward = gameDevDcauReward - devReward;

            IDCAU(DCAU).mint(DEVADDRESS, devReward);
            IDCAU(DCAU).mint(GAMEADDRESS, gameReward);
        }

        dcauTotalSupply = IERC20(DCAU).totalSupply();

        // The first time we reach DCAU's max supply we solidify the end of farming.
        if (dcauTotalSupply >= DCAU_MAX_SUPPLY && emissionEndTime == type(uint256).max) emissionEndTime = block.timestamp;

        pool.accDCAUPerShare = pool.accDCAUPerShare + ((dcauReward * 1e12) / pool.lpSupply);
        pool.lastRewardTime = block.timestamp;
    }

    // Deposit LP tokens to MasterChef for DCAU allocation.
    function deposit(uint256 _pid, uint256 _amount) external nonReentrant {
        require(_pid < poolInfo.length, "Dragon: Non-existent pool");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = ((user.amount * pool.accDCAUPerShare) / 1e12) - user.rewardDebt;
            if (pending > 0) {
                safeDcauTransfer(msg.sender, pending);
            }
        }

        if (_amount > 0) {
            // We are considering tokens which takes accounts fees when trasnsferring such like reflect finance
            IERC20 _lpToken = pool.lpToken;
            {
                uint256 balanceBefore = _lpToken.balanceOf(address(this));
                _lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
                _amount = _lpToken.balanceOf(address(this)) - balanceBefore;
                require(_amount > 0, "We only accept amount > 0");
            }

            if (pool.depositFeeBP > 0) {
                uint256 depositFee = (_amount * pool.depositFeeBP) / 10000;
                // We split this fee to feeAddress and Dragon Nest supporters - 90% 10%
                _lpToken.safeTransfer(FEEADDRESS, (depositFee * 9000) / 10000);

                poolDragonNestInfo[_pid].pendingDepFee += (depositFee * 1000) / 10000;

                user.amount = user.amount + _amount - depositFee;
                pool.lpSupply = pool.lpSupply + _amount - depositFee;
            } else {
                user.amount = user.amount + _amount;
                pool.lpSupply = pool.lpSupply + _amount;
            }
        }

        user.rewardDebt = (user.amount * pool.accDCAUPerShare) / 1e12;

        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        require(_pid < poolInfo.length, "Dragon: Non-existent pool");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "Withdraw: not good");
        updatePool(_pid);
        uint256 pending = ((user.amount * pool.accDCAUPerShare) / 1e12) - user.rewardDebt;
        if (pending > 0) {
            safeDcauTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount - _amount;
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            pool.lpSupply = pool.lpSupply - _amount;
        }
        user.rewardDebt = (user.amount * pool.accDCAUPerShare) / 1e12;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        require(_pid < poolInfo.length, "Dragon: Non-existent pool");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);

        // In the case of an accounting error, we choose to let the user emergency withdraw anyway
        if (pool.lpSupply >= amount) pool.lpSupply = pool.lpSupply - amount;
        else pool.lpSupply = 0;

        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Safe DCAU transfer function, just in case if rounding error causes pool to not have enough DCAUs.
    function safeDcauTransfer(address _to, uint256 _amount) internal {
        uint256 dcauBal = IERC20(DCAU).balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > dcauBal) {
            transferSuccess = IERC20(DCAU).transfer(_to, dcauBal);
        } else {
            transferSuccess = IERC20(DCAU).transfer(_to, _amount);
        }
        require(transferSuccess, "safeDcauTransfer: transfer failed");
    }

    function setStartTime(uint256 _newStartTime) external onlyOwner {
        require(poolInfo.length == 0, "no changing startTime after pools have been added");
        require(block.timestamp < startTime, "cannot change start time if sale has already commenced");
        require(block.timestamp < _newStartTime, "cannot set start time in the past");
        startTime = _newStartTime;

        emit UpdateStartBlock(startTime);
    }

    function setDcauPerSecond(uint256 _dcauPerSecond) external onlyOwner {
        require(_dcauPerSecond <= MAX_EMISSION_RATE, "emissions too high limited to 1 per second");

        massUpdatePools();

        dcauPerSecond = _dcauPerSecond;
        emit SetDCAUPerSecond(_dcauPerSecond);
    }

    function setEmissionEndTime(uint256 _emissionEndTime) external onlyOwner {
        require(_emissionEndTime > block.timestamp, "Emission can not be end in the past");
        emissionEndTime = _emissionEndTime;
        emit SetEmissionEndTime(_emissionEndTime);
    }

    function massUpdatePoolDragonNests() external nonReentrant {
        _massUpdatePoolDragonNests();
    }

    function _massUpdatePoolDragonNests() private {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            _updatePoolDragonNest(pid);
        }
    }

    // Update dragon nest.
    function updatePoolDragonNest(uint256 _pid) external nonReentrant {
        _updatePoolDragonNest(_pid);
    }

    function _updatePoolDragonNest(uint256 _pid) private {
        require(nestSupportersLength > 0, "Must have supporters");

        PoolDragonNestInfo storage poolDragonNest = poolDragonNestInfo[_pid];
        uint256 _pendingDepFee = poolDragonNest.pendingDepFee;

        if (_pendingDepFee > 0) {
            poolDragonNest.accDepFeePerShare += _pendingDepFee / nestSupportersLength;
            poolDragonNest.pendingDepFee = 0;
        }
    }

    /**
     * These functions are private function for using contract internal.
     * These functions will be used when user stakes new DragonNestSupporter
     */
    function massUpdatePoolDragonNestsWithNewToken(uint256 _tokenId) private {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePoolDragonNestWithNewToken(pid, _tokenId);
        }
    }

    function updatePoolDragonNestWithNewToken(uint256 _pid, uint256 _tokenId) private {
        PoolDragonNestInfo storage _poolDragonNestInfo = poolDragonNestInfo[_pid];
        uint256 _pendingDepFee = _poolDragonNestInfo.pendingDepFee;

        uint256 accDepFeePerShare = _poolDragonNestInfo.accDepFeePerShare;
        if (_pendingDepFee > 0 && nestSupportersLength > 0) {
            _poolDragonNestInfo.accDepFeePerShare = accDepFeePerShare + _pendingDepFee / nestSupportersLength;
            _poolDragonNestInfo.pendingDepFee = 0;
        }
        dragonNestInfo[_pid][_tokenId] = accDepFeePerShare;
    }

    function stakeDragonNest(uint256 tokenId) external nonReentrant {
        massUpdatePoolDragonNestsWithNewToken(tokenId);
        IERC721 _dragonNest = IERC721(DRAGON_NEST_SUPPORTER);
        _dragonNest.safeTransferFrom(msg.sender, address(this), tokenId);
        nestSupporters[tokenId] = msg.sender;
        nestSupportersLength++;

        emit DragonNestStaked(msg.sender, tokenId);
    }

    function withdrawDragonNest(uint256 tokenId) external nonReentrant {
        require(nestSupporters[tokenId] == msg.sender, "Dragon: Forbidden");
        nestSupporters[tokenId] = address(0);
        _massUpdatePoolDragonNests();
        // transfer in for loop? It's Okay. We should do with a few number of pools
        uint256 len = poolInfo.length;
        for (uint256 pid = 0; pid < len; pid++) {
            PoolInfo storage pool = poolInfo[pid];
            pool.lpToken.safeTransfer(
                address(msg.sender),
                poolDragonNestInfo[pid].accDepFeePerShare - dragonNestInfo[pid][tokenId]
            );
            dragonNestInfo[pid][tokenId] = 0;
        }

        IERC721 _dragonNest = IERC721(DRAGON_NEST_SUPPORTER);
        _dragonNest.safeTransferFrom(address(this), msg.sender, tokenId);
        nestSupportersLength--;

        emit DragonNestWithdrawn(msg.sender, tokenId);
    }

    // View function to see pending DCAUs on frontend.
    function pendingDcauOfDragonNest(uint256 _pid, uint256 _tokenId) external view returns (uint256) {
        PoolDragonNestInfo storage poolDragonNest = poolDragonNestInfo[_pid];
        uint256 _pendingDepFee = poolDragonNest.pendingDepFee;

        uint256 accDepFeePerShare = 0;

        if (nestSupportersLength > 0) {
            accDepFeePerShare = poolDragonNest.accDepFeePerShare + _pendingDepFee / nestSupportersLength;
        } else {
            accDepFeePerShare = poolDragonNest.accDepFeePerShare + _pendingDepFee;
        }

        return accDepFeePerShare - dragonNestInfo[_pid][_tokenId];
    }

    function stakedAddressForDragonNest(uint256 _tokenId) external view returns (address) {
        require(_tokenId <= 25, "token does not exist");
        return nestSupporters[_tokenId];
    }

    /**
     * @dev This function is used for depositing DCAU from market
     */
    function depositMarketFee(uint256 _pid, uint256 _amount) external nonReentrant {
        require(_pid < poolInfo.length, "pool does not exist");
        require(address(poolInfo[_pid].lpToken) == DCAU, "Should be DCAU pool");
        require(msg.sender == NFT_MARKET, "Available from only market");

        IERC20(DCAU).safeTransferFrom(address(msg.sender), address(this), _amount);
        poolDragonNestInfo[_pid].pendingDepFee += _amount;

        emit MarketDCAUDeposited(msg.sender, _pid, _amount);
    }
}
