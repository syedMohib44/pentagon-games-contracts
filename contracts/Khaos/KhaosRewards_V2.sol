// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../shared/BasicAccessControl.sol";

contract KhaosRewards_V2 is BasicAccessControl {
    using SafeERC20 for IERC20;

    enum REWARDS {
        NONE,
        STARS,
        COINS,
        KARROTS,
        xKHAOS,
        USDT
    }

    event RewardEarned(
        REWARDS rewardType,
        address to,
        uint256 amount,
        uint256 createdAt
    );

    struct Reward {
        REWARDS rewardType;
        uint256 probability; // Scaled to a base of 100000 (e.g., 20% = 20000)
        uint256 amount;
        uint256 cooldown; // Cooldown in seconds
        uint256 claimedCount;
        uint256 claimedMax;
        uint256 lastClaimTime; // Last claim timestamp
    }

    Reward[] public rewards;
    uint256 public constant MAX_WEIGHT = 1000000000;

    IERC20 public xKhaos;
    IERC20 public usdt;

    constructor(IERC20 _xKhaos, IERC20 _usdt) {
        xKhaos = _xKhaos;
        usdt = _usdt;

        rewards.push(Reward(REWARDS.STARS, 350_000_000, 5, 0, 0, 0, 0)); // 35% amt=5
        rewards.push(Reward(REWARDS.STARS, 250_000_000, 10, 0, 0, 0, 0)); // 25% amt=10
        rewards.push(Reward(REWARDS.STARS, 100_000_000, 20, 0, 0, 0, 0)); // 10% amt=20
        rewards.push(Reward(REWARDS.STARS, 20_000_000, 40, 0, 0, 0, 0)); // 2% amt=40

        rewards.push(Reward(REWARDS.COINS, 160_000_000, 10, 0, 0, 0, 0)); // 16% amt=10
        rewards.push(Reward(REWARDS.COINS, 80_000_000, 20, 0, 0, 0, 0)); // 8% amt=20
        rewards.push(Reward(REWARDS.COINS, 40_000_000, 40, 0, 0, 0, 0)); // 4% amt=40

        rewards.push(Reward(REWARDS.KARROTS, 100_000, 10, 0, 0, 0, 0)); // 0.01% amt=10
        rewards.push(Reward(REWARDS.KARROTS, 10_000, 25, 0, 0, 0, 0)); // 0.001% amt=25
        rewards.push(Reward(REWARDS.KARROTS, 1_000, 100, 0, 0, 0, 0)); // 0.0001% amt=100

        rewards.push(
            Reward(
                REWARDS.xKHAOS,
                10,
                100000 * (10 ** 18),
                24 * 60 * 60 * 30,
                0,
                2,
                0
            )
        ); // 0.000001% amt=100000
        rewards.push(
            Reward(REWARDS.USDT, 1, 250 * (10 ** 6), 24 * 60 * 60 * 30, 0, 1, 0)
        ); // 0.0000001%% amt=250
    }

    function claimReward()
        external
        isActive
        returns (REWARDS rewardType, address user, uint256 amount)
    {
        require(msg.sender != address(0), "Invalid address provided");
        uint256 random = randomValue() % MAX_WEIGHT; // Generate a random number between 0-99999
        uint256 cumulativeProbability = 0;

        for (uint256 i = 0; i < rewards.length; i++) {
            Reward storage reward = rewards[i];
            cumulativeProbability += reward.probability;

            if (random < cumulativeProbability) {
                // Check cooldown for high-tier rewards
                if (reward.cooldown > 0) {
                    if (
                        block.timestamp <
                        (reward.lastClaimTime + reward.cooldown)
                    ) {
                        if (reward.claimedMax == 0) {
                            continue;
                        }
                    } else {
                        reward.claimedCount = 0;
                    }
                    if (reward.claimedCount >= reward.claimedMax) continue;
                    if (reward.rewardType == REWARDS.xKHAOS) {
                        require(
                            address(xKhaos) != address(0),
                            "xKHAOS token not supported"
                        );
                        xKhaos.safeTransfer(msg.sender, reward.amount);
                    } else {
                        require(
                            address(usdt) != address(0),
                            "USDT token not supported"
                        );
                        usdt.safeTransfer(msg.sender, reward.amount);
                    }
                    reward.claimedCount += 1;
                }

                // Update last claim time if applicable
                reward.lastClaimTime = block.timestamp;
                emit RewardEarned(
                    reward.rewardType,
                    msg.sender,
                    reward.amount,
                    reward.lastClaimTime
                );
                return (reward.rewardType, msg.sender, reward.amount);
            }
        }
        emit RewardEarned(REWARDS.NONE, msg.sender, 0, block.timestamp);
        return (REWARDS.NONE, msg.sender, 0); // Fallback (shouldn't happen with proper probabilities)
    }

    function setContracts(IERC20 _xKhaos, IERC20 _usdt) external onlyOwner {
        xKhaos = _xKhaos;
        usdt = _usdt;
    }

    function adminWithdrawERC20(
        IERC20 _token,
        uint256 _amount
    ) external onlyOwner {
        bool success = IERC20(_token).transfer(msg.sender, _amount);
        require(success == true, "failed transfer");
    }

    function randomValue() private view returns (uint256) {
        // Generate pseudo-random number using block variables
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        msg.sender
                    )
                )
            );
    }
}
