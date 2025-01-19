import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
import {Freezable} from "../shared/Freezable.sol";

abstract contract IERC677Receiver {
    function onTokenTransfer(
        address _sender,
        uint256 _value,
        bytes memory _data
    ) public virtual;
}

contract LineCityEstate is ERC721, BasicAccessControl, Freezable {
    uint256 public mintCount = 0;
    uint256 public mintMaxCount = 100;

    uint256 constant START_TOKEN = 1;

    bool public isTransferable = false;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    function mintTo(
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
            _tokenId >= START_TOKEN && _tokenId <= mintMaxCount,
            "Token ID is out of range"
        );

        _safeMint(_owner, _tokenId);

        return true;
    }

    function setMax(uint256 _mintMaxCount) external onlyOwner {
        mintMaxCount = _mintMaxCount;
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

    function isContract(address _addr) private view returns (bool hasCode) {
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return length > 0;
    }
}
