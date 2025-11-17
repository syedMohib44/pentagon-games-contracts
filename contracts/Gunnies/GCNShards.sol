// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

/**
 * @title GCNShards
 * @dev An ERC-1155 contract for non-transferable (Soul-Bound) crafting shards.
 * - Minting and burning are restricted to the owner (the Crafting Router).
 * - All user-to-user transfers are disabled.
 */
contract GCNShards is ERC1155, BasicAccessControl {
    constructor()
        ERC1155("https://api.metadata.pentagon.games/gunnies/{id}.json")
    {}

    /**
     * @dev Updates the base URI for the token metadata. Restricted to the owner.
     * This allows changing the location of the metadata files after deployment.
     * @param newURI The new base URI.
     */
    function setURI(string calldata newURI) external onlyOwner {
        _setURI(newURI);
    }

    /**
     * @dev Public function to mint shards. Restricted to the owner.
     * @param to The address to mint shards to.
     * @param designId The design ID of the shard, used as the token ID.
     * @param amount The quantity of shards to mint.
     */
    function mint(
        address to,
        uint256 designId,
        uint256 amount
    ) external onlyModerators {
        _mint(to, designId, amount, "");
    }

    /**
     * @dev Public function to burn shards. Restricted to the owner.
     * @param from The address to burn shards from.
     * @param designId The design ID of the shard, used as the token ID.
     * @param amount The quantity of shards to burn.
     */
    function burn(
        address from,
        uint256 designId,
        uint256 amount
    ) external onlyOwner {
        _burn(from, designId, amount);
    }

    /**
     * @dev Overrides the ERC-1155 hook to enforce non-transferability.
     * Allows minting (from address(0)) and burning (to address(0)).
     * Reverts on any other transfer attempt.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        // Allow only minting (from == 0) and burning (to == 0)
        require(
            from == address(0) || to == address(0),
            "GCNShards: This token is non-transferable"
        );
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
