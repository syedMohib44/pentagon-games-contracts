// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title GCN721Main
 * @dev The main ERC-721 collection for Chromium and Gold NFTs.
 * - Stores TokenData (designId, tier) for each NFT.
 * - Minting and burning are restricted to the owner (the Crafting Router).
 */
contract GCN721Main is ERC721, BasicAccessControl {
    using Counters for Counters.Counter;

    // Struct to hold metadata for each token
    struct TokenData {
        uint16 designId;
        uint8 tier;
    }

    // Counter for safely assigning new token IDs
    Counters.Counter private _tokenIdCounter;

    // Mapping from token ID to its data
    mapping(uint256 => TokenData) private _tokenData;

    // Base URI for constructing token metadata URLs
    string private _baseTokenURI;

    constructor() ERC721("Gunnies Characters", "GCN") {}

    /**
     * @dev Mints a new NFT and assigns its data. Restricted to the owner.
     * @param to The recipient of the new NFT.
     * @param designId The design ID of the character (0-6).
     * @param tier The tier of the NFT (2=Chromium, 3=Gold).
     * @return The ID of the newly minted token.
     */
    function mintTo(
        address to,
        uint16 designId,
        uint8 tier
    ) external onlyModerators returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _tokenData[tokenId] = TokenData(designId, tier);
        return tokenId;
    }

    /**
     * @dev Burns an existing NFT. Restricted to the owner.
     * @param tokenId The ID of the token to burn.
     */
    function burn(uint256 tokenId) external onlyModerators {
        _burn(tokenId);
        delete _tokenData[tokenId];
    }

    /**
     * @dev Returns the TokenData for a given token ID.
     */
    function tokenData(
        uint256 tokenId
    ) external view returns (uint16 designId, uint8 tier) {
        TokenData memory data = _tokenData[tokenId];
        return (data.designId, data.tier);
    }

    /**
     * @dev Returns the URI for a given token ID.
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");
        // Example: https://api.example.com/nfts/3_2.json (TokenID 3, Tier 2)
        return
            string(
                abi.encodePacked(
                    _baseTokenURI,
                    "/",
                    Strings.toString(tokenId),
                    "_",
                    Strings.toString(_tokenData[tokenId].tier),
                    ".json"
                )
            );
    }

    /**
     * @dev Sets the base URI for all token metadata. Can only be called by the owner.
     */
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }
}
