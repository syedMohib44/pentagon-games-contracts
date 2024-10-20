// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IPentaPets} from "../interfaces/IPentaPets.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

contract PentaPets_Distributor is BasicAccessControl, ReentrancyGuard {
    event Mint(address _owner, uint256 token);

    address public pentaPets;

    mapping(uint256 => address) public allowedAddresses;
    mapping(uint256 => uint256) public mintedTokens;

    uint256 public tokenPrice = 100 * (10 ** 18);

    bool public _mintingPaused = false;

    constructor(
        address _pentaPets,
        uint256[] memory _classIds,
        address[] memory _allowedAddresses
    ) {
        pentaPets = _pentaPets;
        for (uint256 index = 0; index < _classIds.length; index++) {
            allowedAddresses[_classIds[index]] = _allowedAddresses[index];
        }
    }

    function setContract(address _pentaPets) external onlyOwner {
        pentaPets = _pentaPets;
    }


    function setAllowedAddress(
        address _allowedAddress,
        uint256 _classId
    ) external onlyOwner {
        allowedAddresses[_classId] = _allowedAddress;
    }

    function mint(uint256 _classId) nonReentrant public returns (bool) {
        IPentaPets pentaPetsContract = IPentaPets(pentaPets);

        // As thing will move in linearly we don't have to worry about tokens minted from between.
        uint256 mintedToken = mintedTokens[_classId] + 1;
        address payableAddress = allowedAddresses[_classId];

        require(!_mintingPaused, "Minting paused");
        require(
            IERC20(payableAddress).balanceOf(msg.sender) >= 100,
            "Insufficient balance"
        );
        // require(msg.value == tokenPrice, "token price is not valid");

        pentaPetsContract.mintNextToken(msg.sender, _classId, mintedToken);
        mintedTokens[_classId] = mintedToken;

        IERC20(payableAddress).transferFrom(
            msg.sender,
            address(this),
            tokenPrice
        );

        emit Mint(msg.sender, mintedToken);
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

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawERC20ByClass(
        uint256 _classId,
        uint256 _amount
    ) public onlyOwner {
        address payableAddress = allowedAddresses[_classId];
        IERC20(payableAddress).transfer(msg.sender, _amount);
    }

    function withdrawERC20(address _token, uint256 _amount) public onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }
}
