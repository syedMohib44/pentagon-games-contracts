

// Sources flattened with hardhat v2.22.9 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File @openzeppelin/contracts/utils/Context.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/shared/BasicAccessControl.sol

// Original license: SPDX_License_Identifier: UNLICENSED

pragma solidity >=0.8.2;

contract BasicAccessControl is Ownable {
    uint16 public totalModerators = 0;
    mapping(address => bool) public moderators;
    bool public isMaintaining = true;

    modifier onlyModerators() {
        require(
            _msgSender() == owner() || moderators[_msgSender()] == true,
            "Restricted Access!"
        );
        _;
    }

    modifier isActive() {
        require(!isMaintaining);
        _;
    }

    function AddModerator(address _newModerator) public onlyOwner {
        if (moderators[_newModerator] == false) {
            moderators[_newModerator] = true;
            totalModerators += 1;
        } else {
            delete moderators[_newModerator];
            totalModerators -= 1;
        }
    }

    function UpdateMaintaining(bool _isMaintaining) public onlyOwner {
        isMaintaining = _isMaintaining;
    }
}


// File contracts/interfaces/IBlockchain_Superheroes.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity >=0.8.0;

interface IBlockchain_Superheroes {
    function mintNextToken(address _owner, uint256 _tokenId) external returns (bool);

    function totalSupply() external view returns (uint256);

    function cap() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);
}


// File contracts/SuperHeroes/BCSH_Distributor.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity >=0.8.2;



contract BCSH_Distributor is BasicAccessControl {
    event Mint(address _owner, uint256 token);

    address public blockchainSuperheroes;

    constructor(address _blockchainSuperheroes) {
        blockchainSuperheroes = _blockchainSuperheroes;
    }

    uint256 public mintingCount = 728_126_428_000_000_000_000;
    uint256 public mintingCap = 728_126_428_000_000_002_500; //  end token id

    uint256 public tokenPrice = 88 * (10 ** 18);

    bool public _mintingPaused = false;

    function setContract(address _blockchainSuperheroes) external onlyOwner {
        blockchainSuperheroes = _blockchainSuperheroes;
    }

    function getBalance(address _owner) public view returns (uint256) {
        IBlockchain_Superheroes blockchainSuperherosContract = IBlockchain_Superheroes(
                blockchainSuperheroes
            );
        return blockchainSuperherosContract.balanceOf(_owner);
    }

    function mintTo(address _owner) public onlyModerators returns (bool) {
        IBlockchain_Superheroes blockchainSuperherosContract = IBlockchain_Superheroes(
                blockchainSuperheroes
            );

        mintingCount++;

        require(!_mintingPaused, "Minting paused");
        require(mintingCount <= mintingCap, "Minting cap reached");

        blockchainSuperherosContract.mintNextToken(_owner, mintingCount);
        emit Mint(_owner, mintingCount);
        return true;
    }

    function mint() public payable returns (bool) {
        IBlockchain_Superheroes blockchainSuperherosContract = IBlockchain_Superheroes(
                blockchainSuperheroes
            );

        mintingCount++;

        require(!_mintingPaused, "Minting paused");
        require(msg.value == tokenPrice, "token price not met");
        require(mintingCount <= mintingCap, "Minting cap reached");

        blockchainSuperherosContract.mintNextToken(msg.sender, mintingCount);
        emit Mint(msg.sender, mintingCount);
        return true;
    }

    fallback() external payable {}

    receive() external payable {}

    function togglePause(bool _pause) public onlyOwner {
        require(_mintingPaused != _pause, "Already in desired pause state");
        _mintingPaused = _pause;
    }

    function updatePrice(uint256 _newPrice) public onlyOwner {
        tokenPrice = _newPrice;
    }

    function setMintingCap(uint256 _mintingCap) external onlyOwner {
        mintingCap = _mintingCap;
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
