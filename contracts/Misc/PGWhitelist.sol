pragma solidity >=0.8.0;

import "../shared/BasicAccessControl.sol";

contract PGWhitelist is BasicAccessControl {
    mapping(address => bool) public deployWhitelist;
    mapping(address => mapping(address => bool)) public withdrawWhitelist;
    // to list
    // from list

    function toggleDeployWhitelist(address _deployer) external onlyModerators {
        require(_deployer != address(0), "Cannot toggle null address");
        deployWhitelist[_deployer] = !deployWhitelist[_deployer];
    }

    function toggleWithdrawWhitelist(address _from, address _to) external onlyModerators {
        require(_from != address(0) && _to != address(0), "Cannot toggle null address");
        withdrawWhitelist[_from][_to] = !withdrawWhitelist[_from][_to];
    }
}
