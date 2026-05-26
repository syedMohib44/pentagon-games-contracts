// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

interface IGunniesSBT {
    function mint(address to, uint256 tokenId) external;
}

contract GunniesDistributorV2 is BasicAccessControl {
    IGunniesSBT public sbtContract;

    uint256 public mintFee = 0.05 ether;    // Mint fee (updateable)
    uint256 private nextTokenId = 10001;    // Start token IDs from 10001

    constructor(address _sbtAddress) {
        sbtContract = IGunniesSBT(_sbtAddress);
    }

    /**
     * @notice Mint a new SBT token by paying the mint fee
     */
    function mintSBT() external payable {
        require(msg.value >= mintFee, "Distributor: Insufficient ETH for mint");

        uint256 tokenId = nextTokenId;
        nextTokenId++;

        sbtContract.mint(msg.sender, tokenId);
    }

    /**
     * @notice Owner can mint directly to any address
     */
    function mintTo(address to) external onlyModerators {
        uint256 tokenId = nextTokenId;
        nextTokenId++;

        sbtContract.mint(to, tokenId);
    }

    /**
     * @notice Update the mint fee (only owner)
     */
    function setMintFee(uint256 _mintFee) external onlyOwner {
        mintFee = _mintFee;
    }

    /**
     * @notice Withdraw contract balance
     */
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
