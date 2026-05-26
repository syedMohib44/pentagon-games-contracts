/**
 *Submitted for verification at Arbiscan.io on 2024-12-11
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract Disperse {
    function dispersePCExactDecimal(
        address[] calldata recipients,
        uint256[] calldata values
    ) external payable {
        require(recipients.length == values.length, "Length mismatch");

        for (uint256 i = 0; i < recipients.length; i++)
            payable(recipients[i]).transfer(values[i]);
    }

    function dispersePCx18Decimal(
        address[] calldata recipients,
        uint256[] calldata values
    ) external payable {
        require(recipients.length == values.length, "Length mismatch");

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 value = values[i] * (10 ** 18);
            payable(recipients[i]).transfer(value);
        }
    }

    function disperseWPCExactDecimal(
        address[] calldata recipients,
        uint256[] calldata values
    ) external {
        require(recipients.length == values.length, "Length mismatch");

        IERC20 token = IERC20(0xAA3d9411DD08FDA149d4545089e241E62EE87860);

        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transfer(recipients[i], values[i]));
        }
    }

    function disperseWPCx18Decimal(
        address[] calldata recipients,
        uint256[] calldata values
    ) external {
        require(recipients.length == values.length, "Length mismatch");

        IERC20 token = IERC20(0xAA3d9411DD08FDA149d4545089e241E62EE87860);

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 value = values[i] * (10 ** 18);
            require(token.transfer(recipients[i], value));
        }
    }

    function disperseTokenExactDecimal(
        IERC20 token,
        address[] calldata recipients,
        uint256[] calldata values
    ) external {
        require(recipients.length == values.length, "Length mismatch");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transfer(recipients[i], values[i]));
        }
    }

    function disperseTokenx18Decimal(
        IERC20 token,
        address[] calldata recipients,
        uint256[] calldata values
    ) external {
        require(recipients.length == values.length, "Length mismatch");

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 value = values[i] * (10 ** 18);
            require(token.transfer(recipients[i], value));
        }
    }
}
