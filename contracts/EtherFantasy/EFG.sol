import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

contract EFG is ERC721, BasicAccessControl {
    address public distributor;
    uint256 private _nextTokenId;
    string private _baseTokenURI;

    mapping(uint256 => bool) public isTransferable;

    // EIP-5192 Events
    event Locked(uint256 tokenId);
    event Unlocked(uint256 tokenId);

    error Soulbound();

    modifier applyLock(uint256 tokenId) {
        if (!isTransferable[tokenId]) revert Soulbound();
        _;
    }

    constructor() ERC721("EtherFantasy Genesis", "EFG") {}

    function setDistributor(address _distributor) external onlyOwner {
        distributor = _distributor;
    }

    function mint(address to) external onlyModerators returns (uint256) {
        uint256 tokenId = ++_nextTokenId;
        _safeMint(to, tokenId);

        // Default: Soulbound
        emit Locked(tokenId);
        return tokenId;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {    // ← added
        _baseTokenURI = baseURI;
    }

    function _baseURI() internal view override returns (string memory) { // ← added
        return _baseTokenURI;
    }

    function setTransferable(
        uint256 tokenId,
        bool enabled
    ) external onlyModerators {
        isTransferable[tokenId] = enabled;

        if (enabled) emit Unlocked(tokenId);
        else emit Locked(tokenId);
    }

    // EIP-5192: Returns locked status
    function locked(uint256 tokenId) external view onlyOwner returns (bool) {
        return !isTransferable[tokenId];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override applyLock(tokenId) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override applyLock(tokenId) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return
            interfaceId == 0xb45a3c0e || super.supportsInterface(interfaceId); // 0xb45a3c0e is ERC5192
    }
}