// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CharacterNFT.sol";
import "./AutoDungeon.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

/**
 * @title PackSales
 * @notice Handles the sale of NFT packs, mints characters, and funds the reward pool.
 */
contract PackSales is BasicAccessControl {
    CharacterNFT public characterNFT;
    AutoDungeon public autoDungeon;

    // Prices are in the native token (e.g., PC on Pentagon Chain)
    // Using 18 decimals for precision. $22 -> 22 * 10^18
    uint256 public constant PACK_PRICE = 0;
    uint256 public constant REWARD_POOL_SHARE = 20 * 1e18;
    uint256 public constant PROTOCOL_SHARE = 2 * 1e18;

    event PackPurchased(
        address indexed buyer,
        uint256 quantity,
        uint256 totalCost
    );

    constructor(address _characterNFTAddress, address _autoDungeonAddress) {
        characterNFT = CharacterNFT(_characterNFTAddress);
        autoDungeon = AutoDungeon(_autoDungeonAddress);
    }

    /**
     * @notice Buys a specified quantity of character packs.
     * @dev Mints new CharacterNFTs and distributes funds to the reward pool and protocol.
     * @param characterIds The number of packs to purchase.
     */
    function buyPack(uint256[] memory characterIds) external payable {
        require(characterIds.length > 0, "Quantity must be greater than 0");
        uint256 totalCost = characterIds.length * PACK_PRICE;
        require(msg.value == totalCost, "Incorrect payment amount");

        // 1. Mint NFTs for the buyer
        for (uint256 i = 0; i < characterIds.length; i++) {
            characterNFT.mint(msg.sender, characterIds[i]);
        }

        // // 2. Forward funds to the reward pool
        // uint256 rewardPoolAmount = characterIds.length * REWARD_POOL_SHARE;
        // if (rewardPoolAmount > 0) {
        //     autoDungeon.fundRewardPool{value: rewardPoolAmount}();
        // }

        emit PackPurchased(msg.sender, characterIds.length, totalCost);
    }

    /**
     * @notice Allows the owner to withdraw accumulated protocol fees.
     */
    function withdrawFees() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    // --- Admin Functions ---
    function setContracts(
        address _characterNFTAddress,
        address _autoDungeonAddress
    ) external onlyOwner {
        characterNFT = CharacterNFT(_characterNFTAddress);
        autoDungeon = AutoDungeon(_autoDungeonAddress);
    }
}
