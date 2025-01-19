import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../shared/BasicAccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PentaPets is ReentrancyGuard, ERC721, BasicAccessControl {
    event MetadataUpdate(uint256 _tokenId);
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    // Class id with limit
    mapping(uint256 => uint256) public classIdsLimit;
    uint256 public distance = 100000;

    uint256 public constant MAX_CLASS_ID = 1254;

    receive() external payable {}

    string public _baseTokenURI =
        "https://api.staging.pentagon_games.io/metadata/bcsh/";

    constructor(
        string memory _name,
        string memory _symbol,
        uint256[] memory _classIdsLimit,
        uint256[] memory _classMaxCap
    ) ERC721(_name, _symbol) {
        for (uint256 index = 0; index < _classIdsLimit.length; index++) {
            classIdsLimit[_classIdsLimit[index]] = _classMaxCap[index];
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;

        uint256 maxTokenId = (MAX_CLASS_ID * distance) +
            classIdsLimit[MAX_CLASS_ID];
        emit BatchMetadataUpdate(1, maxTokenId);
    }

    function mintNextToken(
        address _owner,
        uint256 _classId,
        uint256 _tokenId
    ) external onlyModerators returns (bool) {
        return mint(_owner, _classId, _tokenId);
    }

    function mint(
        address _owner,
        uint256 _classId,
        uint256 _tokenId
    ) internal onlyModerators returns (bool) {
        require(_owner != address(0), "ERC721: mint to the zero address");
        require(_tokenId < classIdsLimit[_classId], "Issues with class ids");
        uint256 tokenId = (_classId * distance) + _tokenId;
        require(!_exists(tokenId), "ERC721: token already minted");

        _safeMint(_owner, tokenId);

        return true;
    }
}
