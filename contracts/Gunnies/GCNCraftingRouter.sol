// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

// Interfaces for interacting with the other contracts
interface GCNShards {
    function mint(address to, uint256 designId, uint256 amount) external;

    function burn(address from, uint256 designId, uint256 amount) external;

    function balanceOf(
        address account,
        uint256 id
    ) external view returns (uint256);
}

interface IGCN721Main {
    function mintTo(
        address to,
        uint16 designId,
        uint8 tier
    ) external returns (uint256);

    function burn(uint256 tokenId) external;

    function tokenData(
        uint256 tokenId
    ) external view returns (uint16 designId, uint8 tier);

    function ownerOf(uint256 tokenId) external view returns (address);
}

/**
 * @title GCNCraftingRouter
 * @dev The central orchestrator for crafting and uncrafting NFTs.
 */
contract GCNCraftingRouter is BasicAccessControl, EIP712 {
    // --- Constants ---
    uint256 public constant SHARDS_PER_CHROMIUM = 100;
    uint256 public constant SHARDS_PER_GOLD = 10;
    uint256 public constant UNCRAFT_RETURN_CHROMIUM = 80;
    uint256 public constant UNCRAFT_RETURN_GOLD = 800;
    uint8 public constant TIER_CHROMIUM = 2;
    uint8 public constant TIER_GOLD = 3;

    // --- State Variables ---
    GCNShards public immutable gcnShards;
    IGCN721Main public immutable gcn721Main;
    IERC20 public feeToken; // The $PC token

    mapping(uint8 => uint256) public craftingFee; // tier => fee amount

    // --- Events ---
    event NFTUncrafted(
        address indexed owner,
        uint16 designId,
        uint256 shardsToReturn
    );

    constructor(
        address _shardsAddress,
        address _mainNftAddress,
        address _feeTokenAddress
    ) EIP712("GCNCraftingRouter", "1") {
        gcnShards = GCNShards(_shardsAddress);
        gcn721Main = IGCN721Main(_mainNftAddress);
        feeToken = IERC20(_feeTokenAddress);
    }

    // --- Admin Functions ---

    function setCraftingFee(uint8 tier, uint256 fee) external onlyOwner {
        craftingFee[tier] = fee;
    }

    // --- Crafting Logic ---

    function craftChromium(uint16 designId) external {
        require(
            gcnShards.balanceOf(msg.sender, designId) >= SHARDS_PER_CHROMIUM,
            "Insufficient shards"
        );

        // _chargeFee(TIER_CHROMIUM);
        gcnShards.burn(msg.sender, designId, SHARDS_PER_CHROMIUM);
        gcn721Main.mintTo(msg.sender, designId, TIER_CHROMIUM);
    }

    function craftGold(uint16 designId) external {
        require(
            gcnShards.balanceOf(msg.sender, designId) >= SHARDS_PER_GOLD,
            "Insufficient shards"
        );

        // _chargeFee(TIER_GOLD);
        gcnShards.burn(msg.sender, designId, SHARDS_PER_GOLD);
        gcn721Main.mintTo(msg.sender, designId, TIER_GOLD);
    }

    // --- Uncrafting Logic ---

    function uncraft(uint256 tokenId) external {
        require(gcn721Main.ownerOf(tokenId) == msg.sender, "Not owner");

        (uint16 designId, uint8 tier) = gcn721Main.tokenData(tokenId);

        gcn721Main.burn(tokenId);

        uint256 shardsToReturn = 0;
        if (tier == TIER_CHROMIUM) {
            shardsToReturn = UNCRAFT_RETURN_CHROMIUM;
        } else if (tier == TIER_GOLD) {
            shardsToReturn = UNCRAFT_RETURN_GOLD;
        }

        require(shardsToReturn > 0, "Invalid tier for uncrafting");

        gcnShards.mint(msg.sender, designId, shardsToReturn);

        emit NFTUncrafted(msg.sender, designId, shardsToReturn);
    }

    // --- Internal Helper ---

    function _chargeFee(uint8 tier) internal {
        uint256 fee = craftingFee[tier];
        if (fee > 0) {
            require(
                feeToken.transferFrom(msg.sender, address(this), fee),
                "Fee transfer failed"
            );
        }
    }
}
