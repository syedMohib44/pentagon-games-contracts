// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

import "../shared/BasicAccessControl.sol";

/**
 * @title EmotiCoinCurve (Stateless Logic Contract)
 * @notice This is a stateless "calculator" contract. It holds no funds or data.
 * The EchoVault contract calls this contract to perform bonding curve math.
 * All constants for the sale are defined here for consistency.
 */
contract EmotiCoinCurveRegistery is BasicAccessControl {
    address public pumpFun;

    constructor(address _pumpFun) {
        pumpFun = _pumpFun;
    }

    function getEmotiCoinCurve() external view returns (address) {
        return pumpFun;
    }

    function setEmotiCoinCurve(address _pumpFun) external onlyOwner {
        pumpFun = _pumpFun;
    }
}
