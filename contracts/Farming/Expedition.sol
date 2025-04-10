// SPDX-License-Identifier: Unlicense

pragma solidity >=0.8.2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface StakeToken {
    function mint(address _to, uint256 _amount) external;

    function addMiner(address _miner) external;

    function removeMiner(address _miner) external;

    //IERC20
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function safeTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Expedition is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct StakeInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 timeStamp;
        uint256 rewardDebt; // how much reward debt pending on user end
    }
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        StakeInfo[] stakeInfo; // this array hold all the stakes enteries for each user
    }
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 lastRewardBlock; // Last block number that Tokens distribution occurs.
        uint256 rewardTokensPerBlock; //  Reward tokens created per block.
        uint256 totalStaked; // total Staked For one pool
        uint256 accTokensPerShare; // Accumulated Tokens per share, times 1e12. See below.
        bool isStopped; // represent either pool is farming or not
        uint256 fromBlock; // fromBlock represent block number from which reward is going to be governed
        uint256 toBlock; // fromBlock represent block number till which multplier remain active
        uint256 actualMultiplier; // represent the mutiplier value that will reamin active until fromBlock and toBlock,
        uint256 lockPeriod; // represent the locktime of pool
        uint256 penaltyPercentage; // represent the penalty percentage incured before withdrawing locktime
        uint256 withdrawFeePercentage; // fee percentage for withdrawfee
    }

    mapping(address => UserInfo) public userInfo;

    address public lockWallet;
    address public withdrawFeeWallet;

    StakeToken public stakingToken;

    uint256 public constant maxLockPeriod = 63072000;

    uint256 public constant maxLockPenaltyPercentage = 100;

    bool public doMint;
    PoolInfo[] public poolInfo;

    event Deposit(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        uint256 accTokensPerShare
    );

    event Withdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        uint256 accTokensPerShare
    );

    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    event UpdateMintStatusEvent(bool doMint);

    event UpdatePoolMultiplierEvent(
        uint256 pid,
        uint256 fromBlock,
        uint256 toBlock,
        uint256 actualMultiplier
    );

    event UpdateLockPeriodEvent(
        uint256 pid,
        uint256 lockPeriod,
        uint256 penaltyPercentage,
        uint256 withdrawFeePercentage
    );

    event StopFarmingEvent(uint256 pid);

    event StartFarmingEvent(uint256 pid, uint256 toBlock);

    event ChangeLockWalletAddressEvent(address lockWallet);

    event ChangeWithdrawFeeWalletAddressEvent(address withdrawFeeWallet);

    event AddPoolEvent(
        address lpToken,
        uint256 fromBlock,
        uint256 toBlock,
        uint256 actualMultiplier,
        uint256 rewardTokensPerBlock,
        uint256 lockPeriod,
        uint256 penaltyPercentage,
        uint256 withdrawFeePercentage
    );

    event SetMinBalanceToStakeEvent(uint256 amount);

    event SetMaxBalanceToStakeEvent(uint256 amount);

    event SetNFTNeededtoStakeEvent(
        address nftAddress,
        bool nft_needed_to_stake_enabled
    );

    event DepositRewardEvent(uint256 amount);

    event WithdrawRewardEvent(uint256 amount);

    event AdminWithdrawERC20Event(uint256 _pid, address token, uint256 amount);

    event AdminWithdrawERC20SimpleEvent(address token, uint256 amount);

    constructor(
        StakeToken _stakingToken,
        bool _doMint,
        address _lockWallet,
        address _withdrawFeeWallet
    ) {
        require(
            address(_lockWallet) != address(0),
            "Cant change to zero address"
        );
        require(
            address(_withdrawFeeWallet) != address(0),
            "Cant change to zero address"
        );

        stakingToken = _stakingToken;
        doMint = _doMint;
        lockWallet = _lockWallet; //TODOAUDIT:
        withdrawFeeWallet = _withdrawFeeWallet; //TODOAUDIT:
    }

    function updateMintStatus(bool _doMint) external onlyOwner {
        doMint = _doMint;

        emit UpdateMintStatusEvent(_doMint);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function updatePoolMultiplier(
        uint256 _pid,
        uint256 _fromBlock, // removed in v2 why?
        uint256 _toBlock,
        uint256 _actualMultiplier
    ) external onlyOwner {
        require(
            _fromBlock < _toBlock,
            "CG Staking: _fromBlock Should be less than _toBlock"
        );
        updatePool(_pid);

        PoolInfo storage pool = poolInfo[_pid];
        pool.fromBlock = _fromBlock;
        pool.toBlock = _toBlock;
        pool.actualMultiplier = _actualMultiplier;

        updatePool(_pid);

        emit UpdatePoolMultiplierEvent(
            _pid,
            _fromBlock,
            _toBlock,
            _actualMultiplier
        );
    }

    function updateLockPeriod(
        uint256 _pid,
        uint256 _lockPeriod,
        uint256 _penaltyPercentage,
        uint256 _withdrawFeePercentage
    ) external onlyOwner {
        require(_lockPeriod < maxLockPeriod, " Lock Period Exceeded ");

        require(
            _penaltyPercentage < maxLockPenaltyPercentage,
            " Lock Percentage Exceeded"
        );

        require(
            _withdrawFeePercentage <= 100,
            " Withdraw Fee Percentage Exceeded"
        );

        PoolInfo storage pool = poolInfo[_pid];
        pool.lockPeriod = _lockPeriod;
        pool.penaltyPercentage = _penaltyPercentage;
        pool.withdrawFeePercentage = _withdrawFeePercentage;

        emit UpdateLockPeriodEvent(
            _pid,
            _lockPeriod,
            _penaltyPercentage,
            _withdrawFeePercentage
        );
    }

    function stopFarming(uint256 _pid) external onlyOwner {
        updatePool(_pid);

        PoolInfo storage pool = poolInfo[_pid];
        pool.isStopped = true;

        emit StopFarmingEvent(_pid);
    }

    function startFarming(uint256 _pid, uint256 _toBlock) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.isStopped, "Already Started");
        pool.isStopped = false;
        pool.lastRewardBlock = block.number;
        pool.toBlock = _toBlock;

        emit StartFarmingEvent(_pid, _toBlock);
    }

    function changeLockWalletAddress(address _lockWallet) external onlyOwner {
        require(
            address(_lockWallet) != address(0),
            "Cant change to zero address"
        );

        lockWallet = _lockWallet;

        emit ChangeLockWalletAddressEvent(_lockWallet);
    }

    function changeWithdrawFeeWalletAddress(
        address _withdrawFeeWallet
    ) external onlyOwner {
        require(
            address(_withdrawFeeWallet) != address(0),
            "Cant change to zero address"
        );

        withdrawFeeWallet = _withdrawFeeWallet;

        emit ChangeWithdrawFeeWalletAddressEvent(_withdrawFeeWallet);
    }

    function addPool(
        IERC20 _lpToken,
        uint256 _fromBlock,
        uint256 _toBlock,
        uint256 _actualMultiplier,
        uint256 _rewardTokensPerBlock,
        uint256 _lockPeriod,
        uint256 _penaltyPercentage,
        uint256 _withdrawFeePercentage
    ) external onlyOwner {
        require(
            _fromBlock < _toBlock,
            "CG Staking: _fromBlock Should be less than _toBlock"
        );
        require(poolInfo.length < 1, "CG Staking: Pool Already Added");
        require(
            address(_lpToken) != address(0),
            "CG Staking: _lpToken should not be address zero"
        );
        require(
            _withdrawFeePercentage <= 100,
            " Withdraw Fee Percentage Exceeded"
        );

        require(
            _penaltyPercentage < maxLockPenaltyPercentage,
            "_penaltyPercentage must be less than the maxLockPenaltyPercentage"
        );
        require(
            _lockPeriod < maxLockPeriod,
            "_lockPeriod must be less than the maxLockPeriod"
        );
        require(
            _toBlock > block.number,
            "_toBlock must be a period in the future"
        );

        uint256 lastRewardBlock = block.number > _fromBlock
            ? block.number
            : _fromBlock;

        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                rewardTokensPerBlock: _rewardTokensPerBlock,
                totalStaked: 0,
                fromBlock: _fromBlock,
                toBlock: _toBlock,
                actualMultiplier: _actualMultiplier,
                lastRewardBlock: lastRewardBlock,
                accTokensPerShare: 0,
                isStopped: false,
                lockPeriod: _lockPeriod,
                penaltyPercentage: _penaltyPercentage,
                withdrawFeePercentage: _withdrawFeePercentage
            })
        );

        emit AddPoolEvent(
            address(_lpToken),
            _fromBlock,
            _toBlock,
            _actualMultiplier,
            _rewardTokensPerBlock,
            _lockPeriod,
            _penaltyPercentage,
            _withdrawFeePercentage
        );
    }

    function getMultiplier(
        uint256 _pid,
        uint256 _from, // pool.lastRewardBlock
        uint256 _to // block.number
    ) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];

        // if block number is before the end time of the pool
        if (_to <= pool.toBlock) {
            return _to.sub(_from).mul(pool.actualMultiplier);
        }
        // if block number is after the end time of the pool
        else {
            // if pool.lastRewardBlock is after pool end then return 0, as all rewards were already claimed
            if (_from > pool.toBlock) {
                return 0;
            } else {
                // if pool.lastRewardBlock is before pool end then return return the final amount to claim up until the pool end time
                return pool.toBlock.sub(_from).mul(pool.actualMultiplier);
            }
        }
    }

    function getLpSupply() public view returns (uint256 _lpSupply) {
        _lpSupply = (lpSupplyTotalDepositedReward).sub(
            lpSupplyTotalWithdrawnReward
        );

        return _lpSupply;
    }

    function pendingReward(
        uint256 _pid,
        address _user
    ) external view returns (uint256, uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_user];
        uint256 accTokensPerShare = pool.accTokensPerShare;

        uint256 lpSupply = getLpSupply();

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                _pid,
                pool.lastRewardBlock,
                block.number
            );

            uint256 totalReward = multiplier.mul(pool.rewardTokensPerBlock);

            accTokensPerShare = accTokensPerShare.add(
                totalReward.mul(1e12).div(lpSupply)
            );

            if (user.amount > 0) {
                uint256 pending = 0;
                uint256 rewardwithoutLockPeriod;
                uint256 currentTimeStamp = block.timestamp;

                for (
                    uint256 index = 0;
                    index < user.stakeInfo.length;
                    index++
                ) {
                    if (user.stakeInfo[index].amount == 0) {
                        continue;
                    }

                    if (
                        (
                            currentTimeStamp.sub(
                                user.stakeInfo[index].timeStamp
                            )
                        ) >= pool.lockPeriod
                    ) {
                        uint256 currentReward = user
                            .stakeInfo[index]
                            .amount
                            .mul(accTokensPerShare)
                            .div(1e12)
                            .sub(user.stakeInfo[index].rewardDebt);
                        pending = pending.add(currentReward);
                        rewardwithoutLockPeriod = rewardwithoutLockPeriod.add(
                            currentReward
                        );
                    } else {
                        uint256 reward = user
                            .stakeInfo[index]
                            .amount
                            .mul(accTokensPerShare)
                            .div(1e12)
                            .sub(user.stakeInfo[index].rewardDebt);
                        rewardwithoutLockPeriod = rewardwithoutLockPeriod.add(
                            reward
                        );
                    }
                }
                return (pending, rewardwithoutLockPeriod);
            }
        }
        return (0, 0);
    }

    // v1.2 User need X Min balance to stake
    uint256 public min_balance_to_stake = 0;

    function setMinBalanceToStake(uint256 _amount) public onlyOwner {
        min_balance_to_stake = _amount;

        emit SetMinBalanceToStakeEvent(_amount);
    }

    // v 1.2 User can only stake Y Max amount
    uint256 public max_balance_to_stake = 1000 * 10 ** 18;

    function setMaxBalanceToStake(uint256 _amount) public onlyOwner {
        max_balance_to_stake = _amount;

        emit SetMaxBalanceToStakeEvent(_amount);
    }

    // v 1.2 User need a specific enablement NFT to stake (can be set as false = do not yet)
    address public nft_needed_to_stake_address = address(0);
    bool public nft_needed_to_stake_enabled = false;

    function setNFTNeededtoStake(
        address _nftAddress,
        bool _nft_needed_to_stake_enabled
    ) public onlyOwner {
        require(
            address(_nftAddress) != address(0),
            "Cant change to zero address"
        );

        nft_needed_to_stake_address = _nftAddress;
        nft_needed_to_stake_enabled = _nft_needed_to_stake_enabled;

        emit SetNFTNeededtoStakeEvent(
            _nftAddress,
            _nft_needed_to_stake_enabled
        );
    }

    uint256 public lpSupplyTotalDepositedReward = 0;
    uint256 public lpSupplyTotalWithdrawnReward = 0;

    function depositReward(uint256 _amount) external onlyOwner {
        lpSupplyTotalDepositedReward = lpSupplyTotalDepositedReward.add(
            _amount
        );

        bool success = stakingToken.transferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        require(success == true, "failed transfer");

        emit DepositRewardEvent(_amount);
    }

    function withdrawReward(uint256 _amount) public onlyOwner {
        lpSupplyTotalWithdrawnReward = lpSupplyTotalWithdrawnReward.add(
            _amount
        );

        bool success = stakingToken.transfer(address(msg.sender), _amount);
        require(success == true, "failed transfer");

        emit WithdrawRewardEvent(_amount);
    }

    // Lets user deposit any amount of Lp tokens
    // 0 amount represent that user is only interested in claiming the reward
    function deposit(uint256 _pid, uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        // v1.2 User need X Min balance to stake
        require(
            user.amount.add(_amount) >= min_balance_to_stake,
            "Staking amount is below minimum balance to stake "
        );
        // v 1.2 User can only stake Y Max amount
        require(
            user.amount.add(_amount) <= max_balance_to_stake,
            "Staking amount is above max balance to stake "
        );
        // v 1.2 User need a specific enablement NFT to stake (can be set as false = do not yet)
        if (nft_needed_to_stake_enabled) {
            // todo: check balance of NFT at nft_needed_to_stake_address
            uint256 balance = IERC721(nft_needed_to_stake_address).balanceOf(
                msg.sender
            );
            require(
                balance > 0,
                "NFT required to stake is enabled and user does not hold any NFTs"
            );
        }

        PoolInfo storage pool = poolInfo[_pid];
        require(
            pool.isStopped == false,
            "Staking Ended, Please withdraw your tokens"
        );
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = 0;

            uint256 currentTimeStamp = block.timestamp;

            for (uint256 index = 0; index < user.stakeInfo.length; index++) {
                if (user.stakeInfo[index].amount == 0) {
                    continue;
                }

                if (
                    (currentTimeStamp.sub((user.stakeInfo[index].timeStamp))) >=
                    pool.lockPeriod
                ) {
                    pending = pending.add(
                        user
                            .stakeInfo[index]
                            .amount
                            .mul(pool.accTokensPerShare)
                            .div(1e12)
                            .sub(user.stakeInfo[index].rewardDebt)
                    );
                    user.stakeInfo[index].rewardDebt = user
                        .stakeInfo[index]
                        .amount
                        .mul(pool.accTokensPerShare)
                        .div(1e12);
                }
            }

            if (pending > 0) {
                uint256 actuallyTransferred_pending = safeStakingTokensTransfer(
                    msg.sender,
                    pending
                );
                lpSupplyTotalWithdrawnReward = lpSupplyTotalWithdrawnReward.add(
                    actuallyTransferred_pending
                );
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
            pool.totalStaked = pool.totalStaked.add(_amount);

            user.stakeInfo.push(
                StakeInfo({
                    amount: _amount,
                    rewardDebt: _amount.mul(pool.accTokensPerShare).div(1e12),
                    timeStamp: block.timestamp
                })
            );
            emit Deposit(
                msg.sender,
                _pid,
                _amount,
                (pool.accTokensPerShare).div(1e12)
            );
        }
    }

    // Lets user withdraw any amount of LPs user needs
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[msg.sender];
        require(
            user.amount >= _amount,
            "withdraw amount higher than the deposited amount"
        );
        updatePool(_pid);

        uint256 totalSelected = 0;
        uint256 rewardForTransfers = 0;
        uint256 totalPenalty = 0;
        uint256 currentTimeStamp = block.timestamp;
        bool timeToBreak = false;

        for (uint256 index = 0; index < user.stakeInfo.length; index++) {
            if (timeToBreak) {
                break;
            }

            if (user.stakeInfo[index].amount == 0) {
                continue;
            }

            uint256 deductionAmount = 0;
            if (totalSelected.add(user.stakeInfo[index].amount) >= _amount) {
                deductionAmount = _amount.sub(totalSelected);
                timeToBreak = true;
            } else {
                deductionAmount = user.stakeInfo[index].amount;
            }

            totalSelected = totalSelected.add(deductionAmount);

            // if the lockperiod is not over for the stake amount then apply panelty

            uint256 currentAmountReward = user
                .stakeInfo[index]
                .amount
                .mul(pool.accTokensPerShare)
                .div(1e12)
                .sub(user.stakeInfo[index].rewardDebt);
            user.stakeInfo[index].amount = user.stakeInfo[index].amount.sub(
                deductionAmount
            );
            uint256 rewardPenalty = (
                currentTimeStamp.sub((user.stakeInfo[index].timeStamp))
            ) < pool.lockPeriod
                ? currentAmountReward.mul(pool.penaltyPercentage).div(10 ** 2)
                : 0;

            rewardForTransfers = rewardForTransfers.add(
                currentAmountReward.sub(rewardPenalty)
            );
            // accumulating penalty amount on each staked withdrawal to be sent to lockwallet
            totalPenalty = totalPenalty.add(rewardPenalty);
            // calculate rewardDebt for the deduction amount
            user.stakeInfo[index].rewardDebt = user
                .stakeInfo[index]
                .amount
                .mul(pool.accTokensPerShare)
                .div(1e12);
        }

        if (rewardForTransfers > 0) {
            uint256 actuallyTransferred_rewardForTransfers = safeStakingTokensTransfer(
                    msg.sender,
                    rewardForTransfers
                );
            lpSupplyTotalWithdrawnReward = lpSupplyTotalWithdrawnReward.add(
                actuallyTransferred_rewardForTransfers
            );
        }
        // penalty amount transfered to lockwallet.
        if (totalPenalty > 0) {
            uint256 actuallyTransferred_totalPenalty = safeStakingTokensTransfer(
                    lockWallet,
                    totalPenalty
                );
            lpSupplyTotalWithdrawnReward = lpSupplyTotalWithdrawnReward.add(
                actuallyTransferred_totalPenalty
            );
        }

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.totalStaked = pool.totalStaked.sub(_amount);

            // new: principal amount fee
            if (pool.withdrawFeePercentage > 0) {
                uint256 principalFee = _amount
                    .mul(pool.withdrawFeePercentage)
                    .div(100);
                uint256 principalLeft = _amount.sub(principalFee);
                pool.lpToken.safeTransfer(withdrawFeeWallet, principalFee); // lockWallet update
                pool.lpToken.safeTransfer(address(msg.sender), principalLeft);
            } else {
                pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }
        }
        emit Withdraw(
            msg.sender,
            _pid,
            _amount,
            (pool.accTokensPerShare).div(1e12)
        );
    }

    // Let the user see stake info for any of deposited LP for frontend
    function getStakeInfo(
        uint256 index
    ) external view returns (uint256, uint256, uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return (
            user.stakeInfo[index].amount,
            user.stakeInfo[index].rewardDebt,
            user.stakeInfo[index].timeStamp
        );
    }

    // Let user see total deposits
    function getUserStakesLength() external view returns (uint256) {
        return userInfo[msg.sender].stakeInfo.length;
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[msg.sender];
        uint256 totalLps = 0;
        for (uint256 index = 0; index < user.stakeInfo.length; index++) {
            if (user.stakeInfo[index].amount > 0) {
                totalLps = totalLps.add(user.stakeInfo[index].amount);
                user.stakeInfo[index].amount = 0;
                user.stakeInfo[index].rewardDebt = 0;
            }
        }
        pool.totalStaked = pool.totalStaked.sub(totalLps);
        pool.lpToken.safeTransfer(address(msg.sender), totalLps);
        emit EmergencyWithdraw(msg.sender, _pid, totalLps);
        user.amount = 0;
    }

    // Update reward variables for all pools. Be careful of gas spending!

    function massUpdatePools() external {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];

        if (block.number <= pool.lastRewardBlock || pool.isStopped) {
            return;
        }

        uint256 lpSupply = getLpSupply();

        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(
            _pid,
            pool.lastRewardBlock,
            block.number
        );

        uint256 stakingReward = multiplier.mul(pool.rewardTokensPerBlock);

        if (doMint) {
            stakingToken.mint(address(this), stakingReward);
        }

        pool.accTokensPerShare = pool.accTokensPerShare.add(
            stakingReward.mul(1e12).div(lpSupply)
        );

        pool.lastRewardBlock = block.number;
    }

    // Transfer reward tokens on users address
    function safeStakingTokensTransfer(
        address _to,
        uint256 _amount
    ) internal returns (uint256) {
        uint256 stakingTokenBalanceOnChef = getLpSupply();

        if (_amount > stakingTokenBalanceOnChef) {
            bool success1 = stakingToken.transfer(
                _to,
                stakingTokenBalanceOnChef
            );
            require(success1 == true, "failed transfer");

            return (stakingTokenBalanceOnChef);
        } else {
            bool success2 = stakingToken.transfer(_to, _amount);
            require(success2 == true, "failed transfer");

            return (_amount);
        }
    }

    function adminWithdrawERC20(
        uint256 _pid,
        address token,
        uint256 amount
    ) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];

        if (address(stakingToken) == address(pool.lpToken)) {
            withdrawReward(amount);
        } else {
            bool success = IERC20(token).transfer(msg.sender, amount);
            require(success == true, "failed transfer");
        }

        emit AdminWithdrawERC20Event(_pid, token, amount);
    }

    function adminWithdrawERC20Simple(
        address token,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amount);

        emit AdminWithdrawERC20SimpleEvent(token, amount);
    }
}
