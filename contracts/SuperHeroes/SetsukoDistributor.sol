// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

interface ISetsukoNFT {
    function ownerOf(uint256 tokenId) external view returns (address);

    function mintNextToken(
        address _owner,
        uint256 _tokenId
    ) external returns (bool);

    function exists(uint256 tokenId) external view returns (bool);
}

contract SetsukoDistributor is BasicAccessControl {
    ISetsukoNFT public setsukoNFT;

    enum Tier {
        BASE,
        DARK,
        OBELITH
    }

    mapping(uint256 => Tier) public tokenTier;
    bool public mintPaused = false;

    uint256 public darkMintedCount;
    uint256 public constant DARK_CAP = 666;
    uint256 public obelithMintedCount;
    uint256 public constant OBELITH_CAP = 66;

    // Prices
    uint256 public darkMintPrice = 5 ether;
    uint256 public obelithUpgradePrice = 15 ether;
    uint256 public obelithDirectPrice = 20 ether;

    uint256 public nextNewTokenId = 5555_000_001_085;

    event TierUpgraded(uint256 indexed tokenId, Tier newTier);
    event DarkMinted(address indexed owner, uint256 tokenId);
    event ObelithMinted(address indexed owner, uint256 tokenId);
    event MintPaused(bool paused);

    constructor(address _setsukoNFT) {
        setsukoNFT = ISetsukoNFT(_setsukoNFT);
    }

    modifier whenNotPaused() {
        require(!mintPaused, "Minting is currently paused");
        _;
    }

    function upgradeToDark(uint256 tokenId) external whenNotPaused {
        require(setsukoNFT.ownerOf(tokenId) == msg.sender, "Not your NFT");
        _internalUpgradeToDark(tokenId);
    }

    function mintDark() external payable whenNotPaused {
        require(msg.value == darkMintPrice, "Incorrect PC amount");
        _internalMintDark(msg.sender);
    }

    function upgradeToObelith(uint256 tokenId) external payable whenNotPaused {
        require(setsukoNFT.ownerOf(tokenId) == msg.sender, "Not your NFT");
        require(msg.value == obelithUpgradePrice, "Incorrect PC amount");
        _internalUpgradeToObelith(tokenId);
    }

    function mintObelith() external payable whenNotPaused {
        require(msg.value == obelithDirectPrice, "Incorrect PC amount");
        _internalMintObelith(msg.sender);
    }

    function mintDarkTo(address to) external onlyModerators {
        _internalMintDark(to);
    }

    function upgradeToDarkTo(uint256 tokenId) external onlyModerators {
        _internalUpgradeToDark(tokenId);
    }

    function mintObelithTo(address to) external onlyModerators {
        _internalMintObelith(to);
    }

    function upgradeToObelithTo(uint256 tokenId) external onlyModerators {
        _internalUpgradeToObelith(tokenId);
    }

    function _internalUpgradeToDark(uint256 tokenId) internal {
        require(tokenTier[tokenId] == Tier.BASE, "Already Dark or higher");
        require(darkMintedCount < DARK_CAP, "Dark cap reached");

        tokenTier[tokenId] = Tier.DARK;
        darkMintedCount++;
        emit TierUpgraded(tokenId, Tier.DARK);
    }

    function _internalMintDark(address to) internal {
        require(darkMintedCount < DARK_CAP, "Dark cap reached");

        uint256 tokenId = nextNewTokenId++;
        darkMintedCount++;
        tokenTier[tokenId] = Tier.DARK;

        require(setsukoNFT.mintNextToken(to, tokenId), "Mint failed");
        emit DarkMinted(to, tokenId);
        emit TierUpgraded(tokenId, Tier.DARK);
    }

    function _internalUpgradeToObelith(uint256 tokenId) internal {
        require(tokenTier[tokenId] == Tier.DARK, "Must be Dark to upgrade");
        require(obelithMintedCount < OBELITH_CAP, "Obelith cap reached");

        tokenTier[tokenId] = Tier.OBELITH;
        obelithMintedCount++;
        emit TierUpgraded(tokenId, Tier.OBELITH);
    }

    function _internalMintObelith(address to) internal {
        require(darkMintedCount < DARK_CAP, "Dark cap reached");
        require(obelithMintedCount < OBELITH_CAP, "Obelith cap reached");

        uint256 tokenId = nextNewTokenId++;
        darkMintedCount++;
        obelithMintedCount++;

        tokenTier[tokenId] = Tier.OBELITH;
        require(setsukoNFT.mintNextToken(to, tokenId), "Mint failed");

        emit ObelithMinted(to, tokenId);
        emit TierUpgraded(tokenId, Tier.OBELITH);
    }

    function setMintPaused(bool _paused) external onlyModerators {
        mintPaused = _paused;
        emit MintPaused(_paused);
    }

    function setNextTokenId(uint256 _newId) external onlyModerators {
        nextNewTokenId = _newId;
    }

    function setTokenTierManual(
        uint256 tokenId,
        Tier _tier
    ) external onlyModerators {
        require(setsukoNFT.exists(tokenId), "Token does not exist");
        tokenTier[tokenId] = _tier;
        emit TierUpgraded(tokenId, _tier);
    }

    function setPrices(
        uint256 _dark,
        uint256 _upgObelith,
        uint256 _dirObelith
    ) external onlyOwner {
        darkMintPrice = _dark;
        obelithUpgradePrice = _upgObelith;
        obelithDirectPrice = _dirObelith;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
