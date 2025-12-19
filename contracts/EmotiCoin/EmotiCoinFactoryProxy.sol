// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract EmotiCoinFactoryProxy is TransparentUpgradeableProxy {
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic, admin_, _data) {}

    /**
     * @dev Upgrades the implementation of the proxy.
     * Only the owner (admin) can call this function.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeTo(newImplementation);
    }

    /**
     * @dev Upgrades the implementation of the proxy and calls a function on the new implementation.
     * This is useful to initialize the upgraded contract.
     * Only the owner (admin) can call this function.
     */
    function upgradeToAndCall(
        address newImplementation,
        bytes calldata data
    ) external ifAdmin {
        _upgradeToAndCall(newImplementation, data);
    }

    /**
     * @dev Internal function to upgrade and call a function on the new implementation.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0) {
            (bool success, ) = address(this).delegatecall(data);
            require(success, "ERC20Proxy: delegatecall failed");
        }
    }
}
