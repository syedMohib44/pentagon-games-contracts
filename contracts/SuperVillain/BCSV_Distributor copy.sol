// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IBlockchain_Supervillains} from "../interfaces/IBlockchain_Supervillains.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

contract BCSV_Distributor is BasicAccessControl {
    using SafeERC20 for IERC20;
    event Mint(address _owner, uint256 token);

    IERC20 public erc20Token;

    address public blockchainSupervillains;

    constructor(address _blockchainSupervillains, IERC20 _erc20Token) {
        blockchainSupervillains = _blockchainSupervillains;
        erc20Token = IERC20(_erc20Token);
    }

    uint256 public mintingCount = 1_482_601_649_000_000_000;
    uint256 public mintingCap = 1_482_601_649_000_002_500;

    uint256 decimal = 18;

    uint256 public nativePriceNFT = 10 * 10 ** decimal;
    uint256 public erc20PriceNFT = 888 * (10 ** 18);

    bool public _mintingPausedNative = false;
    bool public _mintingPausedERC20 = true;

    fallback() external payable {}

    receive() external payable {}

    function setContracts(address _blockchainSupervillains) external onlyOwner {
        blockchainSupervillains = _blockchainSupervillains;
    }


    function mintTo(address _owner) public onlyModerators returns (bool) {
        IBlockchain_Supervillains blockchainSupervillainsContract = IBlockchain_Supervillains(
                blockchainSupervillains
            );

        mintingCount = blockchainSupervillainsContract.currentToken() + 1;

        require(mintingCount <= mintingCap, "Minting cap reached");

        blockchainSupervillainsContract.mintNextToken(_owner);
        emit Mint(_owner, mintingCount);
        return true;
    }

    function mint() external payable isActive returns (bool) {
        IBlockchain_Supervillains blockchainSupervillainsContract = IBlockchain_Supervillains(
                blockchainSupervillains
            );

        mintingCount = blockchainSupervillainsContract.currentToken() + 1;

        require(!_mintingPausedNative, "Minting paused");
        require(msg.value == nativePriceNFT, "token price not met");
        require(mintingCount <= mintingCap, "Minting cap reached");

        blockchainSupervillainsContract.mintNextToken(msg.sender);
        emit Mint(msg.sender, mintingCount);
        return true;
    }

    function erc20Mint(uint256 _amount) external isActive returns (bool) {
        IBlockchain_Supervillains blockchainSupervillainsContract = IBlockchain_Supervillains(
                blockchainSupervillains
            );

        mintingCount = blockchainSupervillainsContract.currentToken() + 1;

        require(!_mintingPausedERC20, "Minting paused");
        require(mintingCount < mintingCap, "Max cap reached");
        require(
            _amount == erc20PriceNFT,
            "Provided amount is invalid or wallet out of funds"
        );

        erc20Token.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        blockchainSupervillainsContract.mintNextToken(msg.sender);
        emit Mint(msg.sender, mintingCount);

        return true;
    }

    function togglePauseNative() public onlyModerators {
        _mintingPausedNative = !_mintingPausedNative;
    }

    function togglePauseERC20() public onlyModerators {
        _mintingPausedERC20 = !_mintingPausedERC20;
    }

    function updateERC20Token(address _erc20Token) public onlyOwner {
        erc20Token = IERC20(_erc20Token);
    }

    function updateNativePrice(uint256 _nativePriceNFT) public onlyOwner {
        nativePriceNFT = _nativePriceNFT;
    }

    function updateERC20Price(uint256 _erc20PriceNFT) public onlyOwner {
        erc20PriceNFT = _erc20PriceNFT;
    }

    function ownerWithdraw(uint256 _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    function ownerWithdrawERC20(
        IERC20 _token,
        uint256 _amount
    ) external onlyOwner {
        bool success = IERC20(_token).transfer(msg.sender, _amount);
        require(success == true, "failed transfer");
    }

    function setMintingCap(uint256 _mintingCap) external onlyOwner {
        mintingCap = _mintingCap;
    }
}
