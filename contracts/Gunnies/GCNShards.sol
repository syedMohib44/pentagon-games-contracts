// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

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
     * @dev Public function to mint shards. Restricted to the owner.
     * @param to The addresses to bulk mint shards to.
     * @param designIds The design IDs of the shard, used as the token ID.
     * @param amounts The quantities of shards to mint.
     */
    function bulkMint(
        address[] memory to,
        uint256[] memory designIds,
        uint256[] memory amounts
    ) external onlyModerators {
        require(to.length == designIds.length);
        bytes memory batchData;

        for (uint256 index = 0; index < to.length; index++) {
            if (designIds[index] == 1) {
                abi.encodePacked(batchData, " Mint#1 ");
            } else if (designIds[index] == 2) {
                abi.encodePacked(batchData, " Mint#2 ");
            } else if (designIds[index] == 3) {
                abi.encodePacked(batchData, " Mint#3 ");
            } else if (designIds[index] == 4) {
                abi.encodePacked(batchData, " Mint#4 ");
            } else if (designIds[index] == 5) {
                abi.encodePacked(batchData, " Mint#5 ");
            } else if (designIds[index] == 6) {
                abi.encodePacked(batchData, " Mint#6 ");
            } else if (designIds[index] == 7) {
                abi.encodePacked(batchData, " Mint#7 ");
            }
            _mint(to[index], designIds[index], amounts[index], batchData);
        }
    }

    /**
     * @dev Public function to mint shards. Restricted to the owner.
     * @param to The address to bulk mint shards to.
     * @param designIds The design IDs of the shard, used as the token ID.
     * @param amounts The quantities of shards to mint.
     */
    function mintBatch(
        address to,
        uint256[] memory designIds,
        uint256[] memory amounts
    ) external onlyModerators {
        bytes memory batchData;
        abi.encodePacked(batchData, " Gunnies with Batch Mint ");
        _mintBatch(to, designIds, amounts, batchData);
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
    ) external onlyModerators {
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
