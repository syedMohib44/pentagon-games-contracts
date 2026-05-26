pragma solidity >=0.8.0;

import "../shared/BasicAccessControl.sol";

contract PGWhitelist is BasicAccessControl {
    mapping(address => bool) public getPCdeployerWhitelist;
    mapping(address => bool) public getPCtoETHBridgeWhitelist;

    function PCdeployerWhitelist(address _deployer) external onlyModerators {
        require(_deployer != address(0), "Cannot toggle null address");
        getPCdeployerWhitelist[_deployer] = !getPCdeployerWhitelist[_deployer];
    }

    function PCtoETHBridgeWhitelist(address _from) external onlyModerators {
        require(_from != address(0), "Cannot toggle null address");
        getPCtoETHBridgeWhitelist[_from] = !getPCtoETHBridgeWhitelist[_from];
    }
}
