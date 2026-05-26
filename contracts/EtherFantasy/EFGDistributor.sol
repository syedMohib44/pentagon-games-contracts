import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
import "./EFG.sol";

contract EFGDistributor is BasicAccessControl {
    //xfer aka Transfer
    EFG public immutable efgContract;
    address payable public treasury;

    uint256 public mintPrice; // e.g., 0.1 PC
    uint256 public upgradePrice; // e.g., 5.0 PC

    // ERC-721L State
    uint8 public defaultTierSBT;
    uint8 public defaultTierXFER;
    mapping(uint8 => string) public tierLicenseURI;
    mapping(uint8 => string) public tierLicenseName;

    mapping(uint256 => uint8) public tokenTierSBTOv;
    mapping(uint256 => uint8) public tokenTierXFEROv;

    event DefaultTiersSet(uint8 sbtTier, uint8 xferTier);
    event TokenTiersSet(uint256 indexed tokenId, uint8 sbtTier, uint8 xferTier);
    event TierURISet(uint8 indexed tier, string uri);
    event TierNameSet(uint8 indexed tier, string name);

    constructor(address _efg, address payable _treasury) {
        efgContract = EFG(_efg);
        treasury = _treasury;

        mintPrice = 0.1 ether; // Placeholder for PC native
        upgradePrice = 5 ether;
    }

    function mint(uint256 quantity) external payable {
        require(msg.value == mintPrice * quantity, "Wrong Price");
        for (uint256 i = 0; i < quantity; i++) {
            efgContract.mint(msg.sender);
        }
        treasury.transfer(msg.value);
    }

    function upgradeTransferable(uint256 tokenId) external payable {
        require(efgContract.ownerOf(tokenId) == msg.sender, "Not Owner");
        require(msg.value == upgradePrice, "Wrong Price");

        efgContract.setTransferable(tokenId, true);
        treasury.transfer(msg.value);
    }

    function revokeTransferable(uint256 tokenId) external onlyModerators {
        efgContract.setTransferable(tokenId, false);
    }

    function setDefaultTiers(uint8 sbt, uint8 xfer) external onlyOwner {
        require(xfer >= sbt, "EFG: NON_MONOTONIC");
        defaultTierSBT = sbt;
        defaultTierXFER = xfer;
        emit DefaultTiersSet(sbt, xfer);
    }

    function setTokenTiers(
        uint256 tokenId,
        uint8 sbt,
        uint8 xfer
    ) external onlyOwner {
        require(xfer >= sbt, "EFG: NON_MONOTONIC");
        tokenTierSBTOv[tokenId] = sbt;
        tokenTierXFEROv[tokenId] = xfer;
        emit TokenTiersSet(tokenId, sbt, xfer);
    }

    function rightsTier(uint256 tokenId) public view returns (uint8) {
        bool isXfer = efgContract.isTransferable(tokenId);
        if (isXfer) {
            return
                tokenTierXFEROv[tokenId] != 0
                    ? tokenTierXFEROv[tokenId]
                    : defaultTierXFER;
        } else {
            return
                tokenTierSBTOv[tokenId] != 0
                    ? tokenTierSBTOv[tokenId]
                    : defaultTierSBT;
        }
    }

    function licenseURI(uint256 tokenId) external view returns (string memory) {
        return tierLicenseURI[rightsTier(tokenId)];
    }

    function licenseName(
        uint256 tokenId
    ) external view returns (string memory) {
        return tierLicenseName[rightsTier(tokenId)];
    }

    function setTierURI(uint8 tier, string memory uri) external onlyOwner {
        tierLicenseURI[tier] = uri;
        emit TierURISet(tier, uri);
    }

    function setTierName(uint8 tier, string memory name) external onlyOwner {
        tierLicenseName[tier] = name;
        emit TierNameSet(tier, name);
    }

    function setPrices(uint256 _mint, uint256 _upgrade) external onlyOwner {
        mintPrice = _mint;
        upgradePrice = _upgrade;
    }
}
