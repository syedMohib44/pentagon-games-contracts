// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./EchoVault.sol";

contract EchoVault_Factory is BasicAccessControl {
    using SafeERC20 for IERC20;
    event Registered(address _owner, address token);

    mapping(address => IERC20) public usersERC20;
    uint256 public fee = 10 * (10 ** 18);

    /**
     *  TOOD: Make Name and Symbol unique
     */
    function registerToken(
        string memory _name,
        string memory _symbol
    ) external payable {
        // require(msg.value == fee, "Invalid amount provided");

        // TODO: Put validation of Token and Name here.
        require(msg.sender != address(0), "Token already exists");

        EchoVault echoVault = new EchoVault(_name, _symbol, fee, msg.sender);
        //TODO: Have to transfer ownership to owner internal wallet
        usersERC20[msg.sender] = echoVault;
        emit Registered(msg.sender, address(echoVault));
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    fallback() external payable {}

    receive() external payable {}
}
