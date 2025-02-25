pragma solidity ^0.8.19;

import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

contract MiningFee is BasicAccessControl {
    event Fee(address owner, uint256 amount, uint256 createAt);

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
    uint256 public resetTime = 24 hours;

    function mineWithFee() external payable {
        require(msg.value == fee, "Fee provided is insufficient");
        UserFee storage userFee = userFeeStatus[msg.sender];

        uint256 currentTime = block.timestamp;
        uint256 resetTimeExpirey = userFee.updatedAt + resetTime;

        require(
            currentTime < resetTimeExpirey ||
                userFee.status == FEE_STATUS.NO_FEE ||
                userFee.status == FEE_STATUS.NONE,
            "User already paid the fee"
        );
        uint256 createdAt = userFee.createdAt;
        if (createdAt == 0) userFee.createdAt = currentTime;
        userFee.updatedAt = currentTime;
        userFee.status = FEE_STATUS.FEE;

        emit Fee(msg.sender, msg.value, block.timestamp);
    }

    function mineWithNoFee() external payable {
        require(msg.value == 0, "No fee required");

        UserFee storage userFee = userFeeStatus[msg.sender];

        uint256 currentTime = block.timestamp;
        uint256 resetTimeExpirey = userFee.updatedAt + resetTime;

        require(
            currentTime < resetTimeExpirey ||
                userFeeStatus[msg.sender].status == FEE_STATUS.NONE,
            "User already paid the fee"
        );
        uint256 createdAt = userFee.createdAt;
        if (createdAt == 0) userFee.createdAt = currentTime;
        userFee.updatedAt = currentTime;
        userFee.status = FEE_STATUS.NO_FEE;

        emit Fee(msg.sender, 0, block.timestamp);
    }

    function updateFee(uint256 _fee) external onlyModerators {
        fee = _fee;
    }

    function updateResetTime(uint256 _resetTime) external onlyModerators {
        resetTime = _resetTime;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "transfer failed");
    }
}
