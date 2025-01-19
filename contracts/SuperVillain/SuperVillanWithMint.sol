// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "@layerzerolabs/solidity-examples/contracts/token/onft/ONFT721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
import {Freezable} from "../shared/Freezable.sol";

contract Blockchain_Superheroes is ONFT721, Freezable, BasicAccessControl {
    event MetadataUpdate(uint256 _tokenId);
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    address public constant BURN_ADDRESS =
        0x000000000000000000000000000000000000dEaD;
    uint256 constant START_TOKEN = 728_126_428_000_000_000_001;
    uint256 _maxCap = 728_126_428_000_000_002_500;

    bool public isTransferable = false;

    // create mapping for mainting gas deposits
    mapping(uint256 => uint256) public tokenDeposits;

    // create mapping for mainting gas burns
    mapping(uint256 => uint256) public tokenBurns;

    mapping(uint256 => uint256) public tokenHighFiversCount;
    mapping(uint256 => address[]) public tokenHighFivers;
    // mapping for maintaining that how many times a user has worshipped a token
    mapping(address => mapping(uint256 => uint256)) public userHighFiversCount;

    //variable to store tokenDeposit value
    uint256 public totalTokenDeposit;

    receive() external payable {}

    string public _baseTokenURI = "https://api.bcsh.xyz/metadata/";

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _minGasToTransfer,
        address _lzEndpoint
    ) ONFT721(_name, _symbol, _minGasToTransfer, _lzEndpoint) {}

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
        uint256 _tokenId
    ) external onlyModerators returns (bool) {
        return mint(_owner, _tokenId);
    }

    function mint(
        address _owner,
        uint256 _tokenId
    ) internal onlyModerators returns (bool) {
        require(_owner != address(0), "ERC721: mint to the zero address");
        require(!_exists(_tokenId), "ERC721: token already minted");
        require(
            _tokenId >= START_TOKEN && _tokenId <= _maxCap,
            "Token ID is out of range"
        );

        _safeMint(_owner, _tokenId);

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

    function SunkenPower(uint256 tokenId) external payable {
        require(
            ownerOf(_tokenId) == msg.sender,
            "You are not the owner of this token"
        );
        (bool success, ) = BURN_ADDRESS.call{value: msg.value}("");
        require(success, "Failed to burn ETH");

        tokenBurns[_tokenId] += msg.value;
    }

    function toggleIsTransferable() public onlyOwner {
        isTransferable = !isTransferable;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount,
        uint256 batchSize
    ) internal virtual override {
        require(
            moderators[_msgSender()] || isTransferable,
            "Cannot transfer to the provided address"
        );
        require(!isFrozen(from), "ERC20Freezable: from account is frozen");
        require(!isFrozen(to), "ERC20Freezable: to account is frozen");
        super._beforeTokenTransfer(from, to, amount, batchSize);
    }

    function freeze(address _account) public onlyOwner {
        freezes[_account] = true;
        emit Frozen(_account);
    }

    function unfreeze(address _account) public onlyOwner {
        freezes[_account] = false;
        emit Unfrozen(_account);
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
