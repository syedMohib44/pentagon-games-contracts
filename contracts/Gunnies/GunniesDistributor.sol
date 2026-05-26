// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

interface IGunniesSBT {
    function mint(address to, uint256 tokenId) external;

    function setUpgradeStatus(uint256 tokenId, bool status) external;

    function ownerOf(uint256 tokenId) external view returns (address);

    function isUpgraded(uint256 tokenId) external view returns (bool);
}

contract GunniesDistributor is BasicAccessControl {
    IGunniesSBT public sbtContract;

    uint256 public mintFee = 0.1 ether;
    uint256 public upgradeFee = 0.1 ether;

    mapping(uint256 => address) public whitelist;

    constructor(address _sbtAddress) {
        sbtContract = IGunniesSBT(_sbtAddress);
    }

    function setWhitelist(
        uint256[] calldata ids,
        address[] calldata users
    ) external onlyModerators {
        require(ids.length == users.length, "Distributor: Length mismatch");
        for (uint256 i = 0; i < ids.length; i++) {
            whitelist[ids[i]] = users[i];
        }
    }

    function mintSBT(uint256 tokenId) external payable {
        require(
            whitelist[tokenId] == msg.sender,
            "Distributor: Not whitelisted for this ID"
        );
        require(msg.value >= mintFee, "Distributor: Insufficient PC for mint");

        sbtContract.mint(msg.sender, tokenId);
    }

    function upgradeToNFT(uint256 tokenId) external payable {
        require(
            sbtContract.ownerOf(tokenId) == msg.sender,
            "Distributor: Not the owner"
        );
        require(
            !sbtContract.isUpgraded(tokenId),
            "Distributor: Already upgraded"
        );
        require(
            msg.value >= upgradeFee,
            "Distributor: Insufficient PC for upgrade"
        );

        sbtContract.setUpgradeStatus(tokenId, true);
    }

    function mintTo(
        address to,
        uint256 tokenId
    ) external onlyModerators {
        sbtContract.mint(to, tokenId);
    }

    function setFees(uint256 _mint, uint256 _upgrade) external onlyOwner {
        mintFee = _mint;
        upgradeFee = _upgrade;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
