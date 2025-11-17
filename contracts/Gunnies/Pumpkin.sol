// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../shared/BasicAccessControl.sol";
import "../shared/Freezable.sol";

contract Pumpkin is
    ERC20("Pumpkin", "PUMP"),
    Freezable,
    BasicAccessControl,
    ReentrancyGuard
{
    mapping(address => bool) public transferable;

    bool public isTransferable = false;
    bool private _internalSpend = false;

    function mint(
        address _to,
        uint256 _amount
    ) external nonReentrant onlyModerators {
        require(!isContract(_to), "Cannot mint to the contract");
        _mint(_to, _amount);
    }

    function bulkMint(
        address[] memory _to,
        uint256[] memory _amount
    ) external onlyModerators {
        for (uint256 index = 0; index < _to.length; index++) {
            require(!isContract(_to[index]), "Cannot mint to the contract");
            _mint(_to[index], _amount[index]);
        }
    }

    function toggleIsTransferable() public onlyOwner {
        isTransferable = !isTransferable;
    }

    function addTransferable(address _transferable) external onlyOwner {
        transferable[_transferable] = true;
    }

    function removeTransferable(address _transferable) external onlyOwner {
        transferable[_transferable] = false;
    }

    function spendPumpkin(uint256 _amount) external nonReentrant {
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance");
        _internalSpend = true;
        super.transfer(address(this), _amount);
        _internalSpend = false;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (!_internalSpend) {
            require(
                moderators[_msgSender()] || isTransferable,
                "Cannot transfer to the provided address"
            );
        }

        require(!isFrozen(from), "ERC20Freezable: from account is frozen");
        require(!isFrozen(to), "ERC20Freezable: to account is frozen");
    }

    function freeze(address _account) public onlyModerators {
        freezes[_account] = true;
        emit Frozen(_account);
    }

    function unfreeze(address _account) public onlyModerators {
        freezes[_account] = false;
        emit Unfrozen(_account);
    }

    function withdrawPumpkin() external onlyModerators {
        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance > 0, "No tokens to withdraw");

        _transfer(address(this), msg.sender, contractBalance);
    }

    function isContract(address _addr) private view returns (bool hasCode) {
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return length > 0;
    }
}
