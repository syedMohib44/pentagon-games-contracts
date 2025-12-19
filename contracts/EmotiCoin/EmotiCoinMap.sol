// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

import "../shared/BasicAccessControl.sol";

contract EmotiCoinMap is BasicAccessControl {
    mapping(address => address) public wallets;

    function mapWallet(
        address externalWallet,
        address internalWallet
    ) external onlyModerators {
        wallets[externalWallet] = internalWallet;
    }
}
