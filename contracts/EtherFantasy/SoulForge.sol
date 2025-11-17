// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CharacterNFT.sol";
import "./AutoDungeon.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

// Placeholder for the bridge contract
interface IEthPackBridgeSoulForge {
    function claimEthPack(address user) external;
}

/**
 * @title SoulForge
 * @notice Allows users to burn their CharacterNFT for a chance at rewards.
 */
contract SoulForge is BasicAccessControl {
    CharacterNFT public characterNFT;
    AutoDungeon public autoDungeon;
    IEthPackBridgeSoulForge public ethPackBridge;

    // Amount to fund the reward pool if that outcome is rolled
    uint256 public constant REWARD_POOL_FUNDING_AMOUNT = 20 * 1e18;

    event Salvaged(
        address indexed player,
        uint256 indexed tokenId,
        string outcome
    );

    constructor(
        address _characterNFT,
        address _autoDungeon,
        address _ethPackBridge
    ) {
        characterNFT = CharacterNFT(_characterNFT);
        autoDungeon = AutoDungeon(_autoDungeon);
        ethPackBridge = IEthPackBridgeSoulForge(_ethPackBridge);
    }

    /**
     * @notice Burns an NFT for a lottery-style reward outcome.
     * @dev User must first call `approve()` on the CharacterNFT contract for this address.
     * @param tokenId The ID of the token to salvage.
     */
    function salvage(uint256 tokenId) external {
        // 1. Burn the NFT. This requires prior approval from the user.
        // The burn function in CharacterNFT will verify msg.sender is this contract.
        characterNFT.burn(tokenId);

        // 2. Roll for the reward outcome
        uint256 seed = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, tokenId))
        );
        uint256 roll = seed % 100;

        if (roll < 30) {
            // 30% chance -> Recharge Elixir
            // In a real system, this would mint an ERC1155 token or update an off-chain state.
            // For MVP, we just emit an event.
            emit Salvaged(msg.sender, tokenId, "Recharge Elixir");
        } else if (roll < 60) {
            // 30% chance -> $20 to AutoDungeon pool
            // This outcome requires the SoulForge contract to be funded by the protocol.
            // For the MVP, we assume it has funds and will attempt the transfer.
            if (address(this).balance >= REWARD_POOL_FUNDING_AMOUNT) {
                autoDungeon.fundRewardPool{value: REWARD_POOL_FUNDING_AMOUNT}();
                emit Salvaged(msg.sender, tokenId, "$20 to Reward Pool");
            } else {
                emit Salvaged(
                    msg.sender,
                    tokenId,
                    "Nothing (insufficient protocol funds)"
                );
            }
        } else if (roll < 65) {
            // 5% chance -> ETH Pack Claim
            ethPackBridge.claimEthPack(msg.sender);
            emit Salvaged(msg.sender, tokenId, "ETH Pack Claim");
        } else {
            // 35% chance -> Nothing
            emit Salvaged(msg.sender, tokenId, "Nothing");
        }
    }

    /**
     * @notice Allows the owner to fund the contract to pay for the "fund reward pool" outcome.
     */
    function depositFunds() external payable onlyOwner {
        // Accepts funds
    }
}
