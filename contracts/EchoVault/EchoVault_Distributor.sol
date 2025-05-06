// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract EchoVault_Distributor is BasicAccessControl {
    using SafeERC20 for IERC20;
    event Mint(address _owner, uint256 token);

    mapping(address => IERC20) public userERC20;

    function registerToken(
        address _owner,
        IERC20 _erc20
    ) external onlyModerators {
        require(_owner != address(0), "Cannot set to null address");
        require(address(_erc20) != address(0), "Cannot set null token address");
        userERC20[_owner] = _erc20;
    }

    fallback() external payable {}

    receive() external payable {}
}
