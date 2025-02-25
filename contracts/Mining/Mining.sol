//TODO: Have to put time bound on determineWinner();

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Mining {
    struct MiningParticipation {
        address user;
        uint256 hashrate;
    }

    struct HashrateCalculation {
        uint256 startingNumber;
        uint256 endingNumber;
        uint256 hashrate;
        address user;
    }

    struct BlockData {
        uint256 blockNo;
        uint256 randomNumber;
        address winnerUser;
        uint256 createdAt;
    }

    struct Reward {
        string symbol;
        string rewardType;
        uint256 amount;
        string status;
        bytes32 txHash;
        address user;
        uint256 blockNo;
        uint256 createdAt;
    }

    mapping(address => MiningParticipation) public miningParticipations;
    HashrateCalculation[] public hashrateCalculations;
    BlockData[] public blocks;
    Reward[] public rewards;
    address[] public participants; // Store addresses of all participants

    uint256 public latestBlockNo;

    event WinnerChosen(address winner, uint256 blockNo, uint256 randomNumber);
    event RewardDistributed(string symbol, uint256 amount, address winner);
    event Participated(address participant, uint256 hashrate);

    function participate(uint256 hashrate) external {
        require(hashrate > 0, "Invalid hashrate");

        if (miningParticipations[msg.sender].hashrate == 0) {
            participants.push(msg.sender); // Only add new participants
        }

        miningParticipations[msg.sender] = MiningParticipation(msg.sender, hashrate);
        emit Participated(msg.sender, hashrate);
    }

    function determineWinner() external {
        delete hashrateCalculations; // Reset calculations
        uint256 totalParticipants = participants.length;
        uint256 startingNumber = 1;

        require(totalParticipants > 0, "No participants");

        for (uint256 i = 0; i < totalParticipants; i++) {
            address user = participants[i];
            MiningParticipation memory participant = miningParticipations[user];

            if (participant.hashrate == 0) continue; // Skip zero hashrate

            uint256 endingNumber = startingNumber + participant.hashrate - 1;

            hashrateCalculations.push(
                HashrateCalculation(startingNumber, endingNumber, participant.hashrate, participant.user)
            );

            startingNumber = endingNumber + 1;
        }

        chooseWinner();
    }

    function chooseWinner() internal {
        require(hashrateCalculations.length > 0, "No participants");

        uint256 smallestNumber = hashrateCalculations[0].startingNumber;
        uint256 highestNumber = hashrateCalculations[hashrateCalculations.length - 1].endingNumber;

        uint256 randomNumber = getRandomNumber(smallestNumber, highestNumber);

        address winner;
        for (uint256 i = 0; i < hashrateCalculations.length; i++) {
            if (randomNumber >= hashrateCalculations[i].startingNumber && randomNumber <= hashrateCalculations[i].endingNumber) {
                winner = hashrateCalculations[i].user;
                break;
            }
        }

        latestBlockNo++;
        blocks.push(BlockData(latestBlockNo, randomNumber, winner, block.timestamp));

        emit WinnerChosen(winner, latestBlockNo, randomNumber);
    }

    function getRandomNumber(uint256 min, uint256 max) internal view returns (uint256) {
        return min + (uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp))) % (max - min + 1));
    }

    function distributeRewards(string memory symbol, uint256 amount, string memory rewardType) external {
        require(blocks.length > 0, "No winners yet");

        address winner = blocks[blocks.length - 1].winnerUser;
        require(winner != address(0), "No valid winner");

        rewards.push(Reward(symbol, rewardType, amount, "pending", "", winner, latestBlockNo, block.timestamp));

        emit RewardDistributed(symbol, amount, winner);
    }
}
