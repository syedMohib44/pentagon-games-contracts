import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../shared/BasicAccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PentaPets is ERC721, BasicAccessControl {
    event MetadataUpdate(uint256 _tokenId);
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    // Class id with limit
    mapping(uint256 => uint256) public classIds;
    uint256 public distance = 100000;

    uint256 _maxCap = (257 * distance) + 10;

    // create mapping for mainting eth deposits
    mapping(uint256 => uint256) public tokenDeposits;

    mapping(uint256 => uint256) public tokenHighFiversCount;
    mapping(uint256 => address[]) public tokenHighFivers;
    // mapping for maintaining that how many times a user has worshipped a token
    mapping(address => mapping(uint256 => uint256)) public userHighFiversCount;

    //variable to store tokenDeposit value
    uint256 public totalTokenDeposit;

    receive() external payable {}

    string public _baseTokenURI =
        "https://api.staging.pentagon_games.io/metadata/bcsh/";

    constructor(
        string memory _name,
        string memory _symbol,
        uint256[] memory _classIds,
        uint256[] memory _classMaxCap
    ) ERC721(_name, _symbol) {
        for (uint256 index = 0; index < _classIds.length; index++) {
            classIds[_classIds[index]] = _classMaxCap[index];
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
        emit BatchMetadataUpdate(1, _maxCap);
    }

    function setMaxCap(uint256 _newCap) external onlyOwner {
        require(_newCap > _maxCap, "New cap must be greater than current cap");
        _maxCap = _newCap;
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
        require(_tokenId < classIds[_classId], "Issues with class ids");
        require(!_exists(_tokenId), "ERC721: token already minted");

        uint256 tokenId = (_classId * distance) + _tokenId;

        _safeMint(_owner, tokenId);

        return true;
    }

    // function to handle deposits of eth for token ids . Only owner of token can deposit eth
    function depositFund(uint256 _tokenId) external payable {
        require(
            ownerOf(_tokenId) == msg.sender,
            "You are not the owner of this token"
        );
        tokenDeposits[_tokenId] += msg.value;
        totalTokenDeposit += msg.value;
    }

    // function to withdraw eth from token deposits
    function withdrawTokenDeposit(uint256 _tokenId, uint256 _amount) external {
        require(
            ownerOf(_tokenId) == msg.sender,
            "You are not the owner of this token"
        );
        require(tokenDeposits[_tokenId] >= _amount, "Insufficient balance");
        tokenDeposits[_tokenId] -= _amount;
        totalTokenDeposit -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    // function to withdraw all token from contract of contract
    function withdrawAll() external onlyOwner {
        require(
            address(this).balance > totalTokenDeposit,
            "No deposite from contract owner"
        );
        payable(msg.sender).transfer(address(this).balance - totalTokenDeposit);
    }

    // function to HighFive a token
    function highFiveToken(uint256 _tokenId) external {
        require(_exists(_tokenId), "Token does not exist");
        tokenHighFiversCount[_tokenId] += 1;
        tokenHighFivers[_tokenId].push(msg.sender);
        userHighFiversCount[msg.sender][_tokenId] += 1;
    }
}
