import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Mining is BasicAccessControl {
    event Mine(uint256 blockNum, uint256 min, uint256 max, uint256 _randomNo);

    function generateRandom(
        uint256 blockNum,
        uint256 min,
        uint256 max
    ) external onlyModerators returns (uint256) {
        uint256 random = min +
            (uint256(
                keccak256(abi.encodePacked(block.prevrandao, block.timestamp))
            ) % (max - min + 1));

        emit Mine(blockNum, min, max, random);
        return random;
    }
}
