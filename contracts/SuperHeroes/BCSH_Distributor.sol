// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IBlockchain_Superheroes} from "../interfaces/IBlockchain_Superheroes.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

contract BCSH_Distributor is BasicAccessControl {
    using SafeERC20 for IERC20;
    event Mint(address _owner, uint256 token);

    IERC20 public erc20Token;

    address public blockchainSuperheroes;

    constructor(address _blockchainSuperheroes) {
        blockchainSuperheroes = _blockchainSuperheroes;
    }

    uint256 public mintingCount = 1_116_000_000_225;
    uint256 public mintingCap = 1_116_000_002_500;

    uint256 public tokenPrice = 10 * (10 ** 18);

    bool public _mintingPaused = true;

    function setContracts(address _blockchainSuperheroes) external onlyOwner {
        blockchainSuperheroes = _blockchainSuperheroes;
    }

    function mintTo(address _owner) external onlyModerators returns (bool) {
        IBlockchain_Superheroes blockchainSuperherosContract = IBlockchain_Superheroes(
                blockchainSuperheroes
            );
        mintingCount++;

        blockchainSuperherosContract.mintNextToken(_owner, mintingCount);

        emit Mint(_owner, mintingCount);
        return true;
    }

    function mint() external payable returns (bool) {
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

    function togglePause() public onlyModerators {
        _mintingPaused = !_mintingPaused;
    }

    function updatePrice(uint256 _newPrice) public onlyOwner {
        tokenPrice = _newPrice;
    }

    function adminWithdraw(uint256 _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    function adminWithdrawERC20(
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
