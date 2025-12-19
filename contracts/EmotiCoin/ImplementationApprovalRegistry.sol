// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../shared/BasicAccessControl.sol";

contract ImplementationApprovalRegistry is BasicAccessControl {
    mapping(address => bool) public approvedImplementation;

    function approveImplementation(address _implementation) external onlyOwner {
        approvedImplementation[_implementation] = true;
    }

    function removeImplementation(address _implementation) external onlyOwner {
        approvedImplementation[_implementation] = false;
    }
}
