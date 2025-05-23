// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract CZ_DailyRunz_Checkin {
    event CheckIn(address _user, uint256 _createdAt);

    function checkIn() external {
        emit CheckIn(msg.sender, block.timestamp);
        return;
    }

    function check() external {
        return;
    }
}
