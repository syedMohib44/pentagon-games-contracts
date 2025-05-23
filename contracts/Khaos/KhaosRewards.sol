// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../shared/BasicAccessControl.sol";

contract KhaosReward is BasicAccessControl {
    using SafeERC20 for IERC20;

    event RewardEarned(address to, uint256 createdAt);
    event AirdropTransfer(
        address token,
        address[] indexed addresses,
        uint256[] indexed values
    );

    fallback() external payable {}

    receive() external payable {}

    function claimReward(
        uint256 _createdAt
    ) external isActive returns (address user, uint256 createdAt) {
        emit RewardEarned(msg.sender, _createdAt);
        return (msg.sender, _createdAt);
    }

    function bulkTransfer(
        address _tokenAddress,
        address[] memory addresses,
        uint256[] memory values
    ) external onlyModerators {
        require(_tokenAddress != address(0), "ERC20 address cannot be null");
        require(addresses.length == values.length, "Length mismatch");

        for (uint256 i = 0; i < addresses.length; i++) {
            IERC20(_tokenAddress).transferFrom(
                msg.sender,
                addresses[i],
                values[i]
            );
        }

        emit AirdropTransfer(_tokenAddress, addresses, values);
    }
}
