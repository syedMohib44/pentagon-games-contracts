// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title IDistributor
 * @dev Interface for the "DistributorMint" contract.
 * The PaymentContract calls this directly for same-chain mints.
 * Assumes a simple mint function; adjust if your Distributor is different.
 */
interface IDistributor {
    /**
     * @notice Mints a new item to a user.
     * @param to The address of the recipient.
     */
    function mintTo(address to) external;
}

/**
 * @title PaymentContract
 * @dev Accepts payments for SKUs, emits an event for a backend listener,
 * and can trigger same-chain mints directly.
 *
 * This contract is designed to be deployed on each chain (ETH, Core, Monad, etc.).
 *
 * It supports payments in:
 * 1. Native chain token (e.g., ETH, CORE) - by using `purchaseWithNative`
 * 2. Any ERC20 token (e.g., USDC, PC) - by using `purchaseWithToken`
 *
 * Admin must first configure prices and SKU types using:
 * - `setPrice(skuId, tokenAddress, price)`
 * - `setSkuConfig(skuId, mintType, distributor)`
 */
contract PaymentProcessor is BasicAccessControl, ReentrancyGuard {
    //=================================================
    //                  Events
    //=================================================

    /**
     * @notice Emitted when a payment is successfully received.
     * This is the primary event the backend listener must track.
     */
    event PaymentReceived(
        uint256 indexed skuId,
        address indexed buyer,
        bool indexed minted
    );

    /**
     * @notice Emitted when a direct, same-chain mint attempt fails.
     * The backend can use this for monitoring and manual intervention.
     * The payment is still considered successful, and PaymentReceived is still emitted.
     */
    event DirectMintFailed(
        uint256 indexed skuId,
        address indexed buyer,
        address distributor
    );

    event DirectMintSuccessful(
        uint256 indexed skuId,
        address indexed buyer,
        address distributor
    );

    /**
     * @notice Emitted when an admin sets a price for a SKU.
     */
    event SkuPriceSet(
        uint256 indexed skuId,
        address indexed token,
        uint256 price
    );

    /**
     * @notice Emitted when an admin configures a SKU's fulfillment logic.
     */
    event SkuConfigSet(
        uint256 indexed skuId,
        MintType mintType,
        address distributor
    );

    //=================================================
    //            Structs, Enums, Constants
    //=================================================

    /**
     * @dev Use address(0) to represent the native chain token (ETH, CORE, etc.)
     * when setting and checking prices.
     */
    address public constant NATIVE_TOKEN = address(0);

    /**
     * @dev Defines whether a SKU purchase is fulfilled
     * by the backend or directly by this contract.
     */
    enum MintType {
        BACKEND, // 0: Emits event for backend fulfillment (cross-chain)
        DIRECT // 1: Calls a local distributor contract (same-chain)
    }

    /**
     * @dev Stores the fulfillment configuration for a specific SKU.
     */
    struct SkuConfig {
        MintType mintType; // BACKEND or DIRECT
        address distributor; // Address of the DistributorMint contract (if DIRECT)
    }

    //=================================================
    //               State Variables
    //=================================================

    /**
     * @dev Maps a SKU ID (uint256) to its fulfillment configuration.
     * e.g., "CORE_HERO" -> { mintType: DIRECT, distributor: 0x... }
     */
    mapping(uint256 => SkuConfig) public skuConfigs;

    /**
     * @dev Maps (SKU ID => Token Address) to its static price.
     * e.g., ("CORE_HERO", 0xUSDC...) -> 15_000_000 (for 15 USDC with 6 decimals)
     * e.g., ("CORE_HERO", NATIVE_TOKEN) -> 0.008 ether
     */
    mapping(uint256 => mapping(address => uint256)) public prices;

    constructor() {}

    /**
     * @notice Set or update the price for a SKU in a specific currency.
     * @param skuId The SKU identifier (e.g., "CORE_HERO")
     * @param token The token address (use address(0) for native token)
     * @param price The price in the token's smallest unit
     * (e.g., wei for native, 1e6 for 6-decimal USDC)
     */
    function setPrice(
        uint256 skuId,
        address token,
        uint256 price
    ) external onlyOwner {
        prices[skuId][token] = price;
        emit SkuPriceSet(skuId, token, price);
    }

    /**
     * @notice Set or update the configuration for a SKU.
     * @param skuId The SKU identifier
     * @param mintType 0 for BACKEND, 1 for DIRECT
     * @param distributor The address of the DistributorMint contract (if DIRECT)
     */
    function setSkuConfig(
        uint256 skuId,
        MintType mintType,
        address distributor
    ) external onlyOwner {
        if (mintType == MintType.DIRECT) {
            require(
                distributor != address(0),
                "Distributor address cannot be zero for DIRECT mints"
            );
        }

        skuConfigs[skuId] = SkuConfig({
            mintType: mintType,
            distributor: distributor
        });
        emit SkuConfigSet(skuId, mintType, distributor);
    }

    //=================================================
    //             Public Purchase Functions
    //=================================================

    /**
     * @notice Purchase an item using the native chain token (ETH, CORE, etc.)
     * @param skuId The SKU identifier to purchase
     */
    function purchaseWithNative(uint256 skuId) external payable nonReentrant {
        uint256 price = prices[skuId][NATIVE_TOKEN];

        require(price > 0, "SKU not for sale in native token");
        require(msg.value == price, "Incorrect native token amount sent");

        _processPayment(skuId, msg.sender);
    }

    /**
     * @notice Purchase an item using an ERC20 token
     * @param skuId The SKU identifier to purchase
     * @param tokenAddress The address of the ERC20 token being used
     */
    function purchaseWithToken(
        uint256 skuId,
        address tokenAddress
    ) external nonReentrant {
        require(
            tokenAddress != NATIVE_TOKEN,
            "Use purchaseWithNative for native token"
        );

        uint256 price = prices[skuId][tokenAddress];
        require(price > 0, "SKU not for sale in this token");

        // --- Payment ---
        // Securely transfer the token from the user to this contract.
        // **IMPORTANT**: The user MUST approve this contract to spend their
        // tokens *before* calling this function.
        IERC20 token = IERC20(tokenAddress);
        bool success = token.transferFrom(msg.sender, address(this), price);
        require(success, "ERC20 transfer failed");

        // --- Fulfillment ---
        _processPayment(skuId, msg.sender);
    }

    //=================================================
    //                Internal Logic
    //=================================================

    /**
     * @notice Internal function to handle fulfillment after payment is confirmed.
     * This is the core logic that emits the event and attempts a direct mint.
     */
    function _processPayment(uint256 skuId, address buyer) internal {
        // 1. **Emit the event for the backend.**
        // This is the most critical step, as it allows the backend to work
        // regardless of whether the direct mint succeeds or fails.
        bool minted = false;

        // 2. **Check for same-chain (DIRECT) mint.**
        SkuConfig storage config = skuConfigs[skuId];

        if (config.mintType == MintType.DIRECT) {
            // Attempt to call the distributor contract.
            // We use a try/catch block to ensure the transaction does NOT revert
            // if the direct mint fails. We still want the PaymentReceived
            // event to be logged for the backend.
            try IDistributor(config.distributor).mintTo(buyer) {
                minted = true;
                emit DirectMintSuccessful(skuId, buyer, config.distributor);
            } catch {
                // Direct mint failed. Emit a failure event for monitoring.
                // The backend can see this and decide to retry or flag for review.
                emit DirectMintFailed(skuId, buyer, config.distributor);
            }
        }

        emit PaymentReceived(skuId, buyer, minted);
    }

    //=================================================
    //              Fund Withdrawal
    //=================================================

    /**
     * @notice Allows the owner to withdraw collected native tokens
     */
    function withdrawNative() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No native funds to withdraw");
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Native withdrawal failed");
    }

    /**
     * @notice Allows the owner to withdraw collected ERC20 tokens
     */
    function withdrawToken(address tokenAddress) external onlyOwner {
        require(tokenAddress != NATIVE_TOKEN, "Use withdrawNative");
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        bool success = token.transfer(owner(), balance);
        require(success, "Token withdrawal failed");
    }
}
