// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

contract MiningFee is BasicAccessControl {
    event Fee(address indexed owner, uint256 amount, uint256 createdAt);

    struct UserFee {
        FEE_STATUS status;
        uint256 createdAt;
        uint256 updatedAt;
    }

    enum FEE_STATUS {
        NONE,
        NO_FEE,
        FEE
    }

    mapping(address => UserFee) public userFeeStatus;

    uint256 public fee = 1 ether;


    function mineWithFee() external payable {
        require(msg.value == fee, "Fee provided is insufficient");

        UserFee storage userFee = userFeeStatus[msg.sender];


        if (userFee.createdAt == 0) {
            userFee.createdAt = block.timestamp;
        }

        userFee.updatedAt = block.timestamp;
        userFee.status = FEE_STATUS.FEE;

        emit Fee(msg.sender, msg.value, block.timestamp);
    }

    function mineWithNoFee() external {
        UserFee storage userFee = userFeeStatus[msg.sender];

        if (userFee.createdAt == 0) {
            userFee.createdAt = block.timestamp;
        }

        userFee.updatedAt = block.timestamp;
        userFee.status = FEE_STATUS.NO_FEE;

        emit Fee(msg.sender, 0, block.timestamp);
    }

    function updateFee(uint256 _fee) external onlyModerators {
        fee = _fee;
    }


    function withdraw() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "transfer failed");
    }
}
