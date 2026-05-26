// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

contract Gunnies is ERC721, BasicAccessControl {

    mapping(uint256 => bool) public isUpgraded;

    event TokenUpgraded(uint256 indexed tokenId);

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {}

    /**
     * @dev Minting function reserved for the Distributor (Moderator)
     */
    function mint(address to, uint256 tokenId) external onlyModerators {
        _safeMint(to, tokenId);
    }

    /**
     * @dev Unlocks the Soulbound restriction. Reserved for Distributor.
     */
    function setUpgradeStatus(
        uint256 tokenId,
        bool status
    ) external onlyModerators {
        require(_exists(tokenId), "SBT: Token does not exist");
        isUpgraded[tokenId] = status;
        emit TokenUpgraded(tokenId);
    }

    /**
     * @dev Overriding the hook from source.
     * This logic prevents all transfers unless the token is upgraded.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        // If from == 0: Minting (Allowed)
        // If to == 0: Burning (Allowed)
        // If both non-zero: Transfer (Only allowed if isUpgraded is true)
        if (from != address(0) && to != address(0)) {
            // We check the firstTokenId for the batch.
            // In a standard transfer, batchSize is always 1.
            require(
                isUpgraded[firstTokenId],
                "SBT: Token is soulbound. Upgrade required to transfer."
            );
        }
    }
}
