// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../shared/BasicAccessControl.sol";

contract KhaosReward is BasicAccessControl {
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

    IERC20 public xKhaos;
    IERC20 public usdt;

    constructor(IERC20 _xKhaos, IERC20 _usdt) {
        xKhaos = _xKhaos;
        usdt = _usdt;
    }

    function claimReward(
        REWARDS _rewardType,
        address _to,
        uint256 _amount,
        uint256 _createdAt
    )
        external
        onlyModerators
        isActive
        returns (REWARDS rewardType, address user, uint256 amount)
    {
        if (_rewardType == REWARDS.USDT) {
            bool success = IERC20(usdt).transfer(_to, _amount);
            require(success == true, "failed transfer");
        } else if (_rewardType == REWARDS.xKHAOS) {
            bool success = IERC20(xKhaos).transfer(_to, _amount);
            require(success == true, "failed transfer");
        }

        emit RewardEarned(_rewardType, _to, _amount, _createdAt);
        return (_rewardType, _to, _amount); // Fallback (shouldn't happen with proper probabilities)
    }

    function setContracts(IERC20 _xKhaos, IERC20 _usdt) external onlyOwner {
        xKhaos = _xKhaos;
        usdt = _usdt;
    }

    function ownerWithdrawERC20(
        IERC20 _token,
        uint256 _amount
    ) external onlyOwner {
        bool success = IERC20(_token).transfer(msg.sender, _amount);
        require(success == true, "failed transfer");
    }
}
