// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CharacterNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

// Forward declaration for SoulForge contract
interface ISoulForge {
    function grantEthPackClaim(address user) external;
}

// Placeholder for the bridge contract
interface IEthPackBridge {
    function claimEthPack(address user) external;
}

/**
 * @title AutoDungeon
 * @notice Main battle session engine, reward vault, and RNG logic.
 */
contract AutoDungeon is BasicAccessControl {
    CharacterNFT public characterNFT;
    IEthPackBridge public ethPackBridge;

    // --- Enums for clarity ---
    enum OutcomeType {
        PvP,
        Monster,
        Boss,
        Trap,
        Treasure
    }
    enum RewardType {
        None,
        RechargeElixir,
        EthPack
    }

    // --- Structs ---
    struct BattleResult {
        OutcomeType outcome;
        bool wasBurned;
        RewardType reward;
    }

    // --- State Variables ---
    uint256 public constant ETH_PACK_UNLOCK_THRESHOLD = 400 * 1e18;
    mapping(uint256 => mapping(uint256 => BattleResult)) public sessionResults; // sessionId => tokenId => result
    uint256 public currentSessionId;

    // --- Events ---
    event DungeonEntered(
        uint256 indexed sessionId,
        address indexed player,
        uint256[] tokenIds
    );
    event BattleOutcome(
        uint256 indexed sessionId,
        uint256 indexed tokenId,
        OutcomeType outcome,
        bool burned
    );
    event TreasureDrop(
        uint256 indexed sessionId,
        uint256 indexed tokenId,
        RewardType reward
    );
    event SessionResolved(uint256 indexed sessionId);

    constructor(address _characterNFTAddress, address _ethPackBridgeAddress) {
        characterNFT = CharacterNFT(_characterNFTAddress);
        ethPackBridge = IEthPackBridge(_ethPackBridgeAddress);
    }

    /**
     * @notice Entrypoint for players to submit up to 3 NFTs to the current dungeon session.
     * @param tokenIds An array of token IDs the player wishes to enter.
     */
    function enterDungeon(uint256[] calldata tokenIds) external {
        require(
            tokenIds.length > 0 && tokenIds.length <= 3,
            "Must enter 1 to 3 NFTs"
        );

        for (uint i = 0; i < tokenIds.length; i++) {
            require(
                characterNFT.ownerOf(tokenIds[i]) == msg.sender,
                "Not the owner of all tokens"
            );
        }

        emit DungeonEntered(currentSessionId, msg.sender, tokenIds);
        // For simplicity, battle is resolved immediately upon entry in this MVP.
        // A production system would batch these entries.
        _resolveBattle(msg.sender, tokenIds);
    }

    /**
     * @notice Internal function to resolve battles for a player's entered NFTs.
     * @dev Contains the core RNG and combat logic.
     */
    function _resolveBattle(address player, uint256[] memory tokenIds) private {
        bool ethPackUnlocked = address(this).balance >=
            ETH_PACK_UNLOCK_THRESHOLD;

        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 seed = uint256(
                keccak256(abi.encodePacked(block.timestamp, player, tokenId))
            );

            uint256 outcomeRoll = seed % 100;
            BattleResult storage result = sessionResults[currentSessionId][
                tokenId
            ];

            // Determine event type based on RNG roll
            if (outcomeRoll < 10) {
                // 10% PvP
                result.outcome = OutcomeType.PvP;
                // Simplified: 5% burn chance on loss (simulated loss)
                if ((seed >> 8) % 100 < 5) result.wasBurned = true;
            } else if (outcomeRoll < 20) {
                // 10% Monster
                result.outcome = OutcomeType.Monster;
                // Simplified battle logic
                if (!_isBattleWon(tokenId, 100)) {
                    // Monster with 100 base power
                    if ((seed >> 8) % 100 < 5) result.wasBurned = true;
                }
            } else if (outcomeRoll < 25) {
                // 5% Boss
                result.outcome = OutcomeType.Boss;
                if (!_isBattleWon(tokenId, 150)) {
                    // Boss with 150 base power
                    if ((seed >> 8) % 100 < 5) result.wasBurned = true;
                }
            } else if (outcomeRoll < 30) {
                // 5% Trap
                result.outcome = OutcomeType.Trap;
                if (!_isTrapSurvived(tokenId)) {
                    if ((seed >> 8) % 100 < 5) result.wasBurned = true;
                }
            } else {
                // 70% Treasure
                result.outcome = OutcomeType.Treasure;
                // Check for ETH pack drop if pool is large enough
                if (ethPackUnlocked && (seed >> 16) % 100 < 1) {
                    // 1% chance
                    result.reward = RewardType.EthPack;
                    ethPackBridge.claimEthPack(player);
                    emit TreasureDrop(
                        currentSessionId,
                        tokenId,
                        RewardType.EthPack
                    );
                }
                // Other treasure logic (e.g., Elixirs) can be added here
            }

            emit BattleOutcome(
                currentSessionId,
                tokenId,
                result.outcome,
                result.wasBurned
            );
        }
    }

    /**
     * @notice Simple combat simulation.
     */
    function _isBattleWon(
        uint256 tokenId,
        uint16 monsterPower
    ) private view returns (bool) {
        CharacterNFT.Stats memory stats = characterNFT.getStats(tokenId);
        return (stats.atk + stats.def) > monsterPower;
    }

    /**
     * @notice Simple trap survival check.
     */
    function _isTrapSurvived(uint256 tokenId) private view returns (bool) {
        CharacterNFT.Stats memory stats = characterNFT.getStats(tokenId);
        return (stats.def + stats.hp) > 200; // Arbitrary survival threshold
    }

    /**
     * @notice Advances the game to the next session.
     * @dev In a real game, this would be called periodically by a trusted account or keeper.
     */
    function advanceSession() external onlyOwner {
        emit SessionResolved(currentSessionId);
        currentSessionId++;
    }

    /**
     * @notice Public payable function to receive funds from PackSales or SoulForge.
     */
    function fundRewardPool() external payable {
        // Function body is empty as it only needs to accept ETH/native token
    }

    /**
     * @notice Retrieves the result for a specific token in a specific session.
     */
    function getBattleResult(
        uint256 sessionId,
        uint256 tokenId
    ) external view returns (BattleResult memory) {
        return sessionResults[sessionId][tokenId];
    }
}
