// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract RewardSystem {
    event RewardEarned(uint256 points, uint256 banana, uint256 createdAt);

    struct Reward {
        uint256 probability; // Scaled to a base of 100000 (e.g., 20% = 20000)
        uint256 points;
        uint256 banana;
        uint256 cooldown; // Cooldown in seconds
        uint256 lastClaimTime; // Last claim timestamp
    }

    Reward[] public rewards;

    constructor() {
        // Initialize rewards
        rewards.push(Reward(20000, 0, 0, 0, 0)); // 20% p=0 b=0
        rewards.push(Reward(35000, 50, 0, 0, 0)); // 35% p=50 b=0
        rewards.push(Reward(25000, 100, 0, 0, 0)); // 25% p=100 b=0
        rewards.push(Reward(14000, 200, 0, 0, 0)); // 14% p=200 b=0
        rewards.push(Reward(5000, 500, 0, 0, 0)); // 5% p=500 b=0
        rewards.push(Reward(79, 0, 1000, 20 * 60, 0)); // 0.79% (20 min cooldown) p=0 b=1000
        rewards.push(Reward(10, 0, 2000, 60 * 60, 0)); // 0.1% (1-hour cooldown) p=0 b=2000
        rewards.push(Reward(10, 0, 5000, 4 * 60 * 60, 0)); // 0.1% (4-hour cooldown) p=0 b=5000
        rewards.push(Reward(1, 0, 10000, 24 * 60 * 60, 0)); // 0.01% (1-day cooldown) p=0 b=10000
    }

    function claimReward() external returns (uint256 _points, uint256 _banana) {
        uint256 random = randomValue() % 100000; // Generate a random number between 0-99999
        uint256 cumulativeProbability = 0;

        for (uint256 i = 0; i < rewards.length; i++) {
            Reward storage reward = rewards[i];
            cumulativeProbability += reward.probability;

            if (random < cumulativeProbability) {
                // Check cooldown for high-tier rewards
                if (
                    reward.cooldown > 0 &&
                    block.timestamp < reward.lastClaimTime + reward.cooldown
                ) {
                    continue; // Skip reward if still in cooldown
                }

                // Update last claim time if applicable
                reward.lastClaimTime = block.timestamp;
                emit RewardEarned(
                    reward.points,
                    reward.banana,
                    reward.lastClaimTime
                );
                return (reward.points, reward.banana);
            }
        }
        emit RewardEarned(0, 0, block.timestamp);
        return (0, 0); // Fallback (shouldn't happen with proper probabilities)
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
