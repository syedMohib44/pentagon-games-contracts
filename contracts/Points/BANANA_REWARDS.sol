// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

contract RewardSystem is BasicAccessControl {
    event RewardEarned(address to, uint256 banana, uint256 createdAt);

    struct Reward {
        uint256 probability; // Scaled to a base of 100000 (e.g., 20% = 20000)
        uint256 banana;
        uint256 cooldown; // Cooldown in seconds
        uint256 lastClaimTime; // Last claim timestamp
    }

    Reward[] public rewards;

    constructor() {
        // Initialize rewards
        // TODO: Rmeove points from rewards replace with banana
        rewards.push(Reward(20000, 0, 0, 0)); // 20% b=0
        rewards.push(Reward(35000, 50, 0, 0)); // 35% b=50
        rewards.push(Reward(25000, 100, 0, 0)); // 25% b=100
        rewards.push(Reward(14000, 200, 0, 0)); // 14% b=200
        rewards.push(Reward(5000, 0, 500, 0)); // 5% b=500
        rewards.push(Reward(79, 1000, 20 * 60, 0)); // 0.79% (20 min cooldown) p=0 b=1000
        rewards.push(Reward(10, 2000, 60 * 60, 0)); // 0.1% (1-hour cooldown) p=0 b=2000
        rewards.push(Reward(10, 5000, 4 * 60 * 60, 0)); // 0.1% (4-hour cooldown) p=0 b=5000
        rewards.push(Reward(1, 10000, 24 * 60 * 60, 0)); // 0.01% (1-day cooldown) p=0 b=10000
    }

    //TODO: Can disable the contract and remove the contract (Idon)
    //TODO: Need to provide user address in parameter
    function claimReward(
        address _user
    ) external onlyModerators isActive returns (address user, uint256 banana) {
        require(_user != address(0), "Invalid address provided");
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
                emit RewardEarned(_user, reward.banana, reward.lastClaimTime);
                return (_user, reward.banana);
            }
        }
        emit RewardEarned(_user, 0, block.timestamp);
        return (_user, 0); // Fallback (shouldn't happen with proper probabilities)
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
