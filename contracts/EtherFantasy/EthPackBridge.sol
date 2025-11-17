// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";


/**
 * @title EthPackBridge_Pentagon
 * @notice Deployed on the L2 (Pentagon Chain).
 * Mints an "EthClaimToken" when called by an authorized contract (AutoDungeon or SoulForge).
 * This claim token would then be bridged to Ethereum Mainnet.
 */
contract EthPackBridge is ERC721, BasicAccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    address public autoDungeonContract;
    address public soulForgeContract;

    modifier onlyAuthorized() {
        require(
            msg.sender == autoDungeonContract ||
                msg.sender == soulForgeContract,
            "Caller is not authorized"
        );
        _;
    }

    constructor() ERC721("ETH Pack Claim Token", "EPCT") {}

    /**
     * @notice Mints a claim token to a user.
     * @dev This is the starting point of the cross-chain claim process.
     */
    function claimEthPack(address user) external onlyAuthorized {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(user, tokenId);
    }

    function setAuthorizedContracts(
        address _autoDungeon,
        address _soulForge
    ) external onlyOwner {
        autoDungeonContract = _autoDungeon;
        soulForgeContract = _soulForge;
    }
}

// /**
//  * @title EthPackBridge_Ethereum
//  * @notice Deployed on L1 (Ethereum Mainnet).
//  * Allows a user to burn their bridged Claim Token to mint a premium ETH-layer NFT.
//  */
// contract EthPackBridge_Ethereum is BasicAccessControl {
//     // This is the premium NFT on Ethereum
//     ERC721 public premiumEthNFT;
//     // This would be the address of the bridged ERC721 claim token on Ethereum
//     // ERC721 public bridgedClaimToken;

//     // --- Events ---
//     event PremiumNftClaimed(
//         address indexed user,
//         uint256 claimId,
//         uint256 newEthNftId
//     );

//     // address _premiumNftAddress,
//     // address _bridgedClaimTokenAddress
//     constructor(address _premiumNftAddress) Ownable(initialOwner) {
//         premiumEthNFT = ERC721(_premiumNftAddress);
//         // bridgedClaimToken = ERC721(_bridgedClaimTokenAddress);
//     }

//     /**
//      * @notice The final step. The user calls this after bridging their claim token to mainnet.
//      * @dev It verifies ownership of the claim token, burns it, and mints the final premium NFT.
//      * @param ethClaimId The ID of the bridged claim token.
//      */
//     function claimAndReveal(uint256 ethClaimId) external {
//         // 1. Verify the user owns the claim token on this chain
//         // require(
//         //     bridgedClaimToken.ownerOf(ethClaimId) == msg.sender,
//         //     "Not owner of claim token"
//         // );

//         // 2. Burn the claim token to prevent re-use
//         // Note: The bridged token contract must have a burn function callable by this bridge contract.
//         // This is a simplified representation.
//         // IBurnable(address(bridgedClaimToken)).burn(ethClaimId);

//         // 3. Mint the premium NFT
//         // The premium NFT contract must authorize this bridge contract to mint.
//         // IMintable(address(premiumEthNFT)).mint(msg.sender);

//         // For demonstration, we'll just emit an event.
//         emit PremiumNftClaimed(msg.sender, ethClaimId, 0); // Placeholder for new NFT ID
//     }
// }
