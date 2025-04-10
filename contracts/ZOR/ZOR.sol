import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
import {Freezable} from "../shared/Freezable.sol";

contract ZOR is
    ERC20,
    ERC20Burnable,
    ERC20Permit,
    Freezable,
    BasicAccessControl
{
    bool public isTransferable = true;
    uint256 public maxSupply = 1_00_000 * 10 ** 18;

    constructor() ERC20("ZOR", "ZOR") ERC20Permit("ZOR") {
        isTransferable = false;
    }

    function toggleIsTransferable() external onlyOwner {
        isTransferable = !isTransferable;
    }

    function updateSupply(uint256 _supply) public onlyOwner {
        require(
            (totalSupply() + _supply) <= maxSupply,
            "Cannot mint more than max supply"
        );
        _mint(msg.sender, _supply);
    }

    function updateMaxSupply(uint256 _maxSupply) public onlyOwner {
        require(
            _maxSupply > totalSupply(),
            "Max supply cannot be less than current total supply"
        );
        maxSupply = _maxSupply;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(
            moderators[_msgSender()] || isTransferable,
            "Cannot transfer to the provided address"
        );
        require(!isFrozen(from), "ERC20Freezable: from account is frozen");
        require(!isFrozen(to), "ERC20Freezable: to account is frozen");
    }

    function freeze(address _account) public onlyModerators {
        freezes[_account] = true;
    }

    function unfreeze(address _account) public onlyModerators {
        freezes[_account] = false;
    }
}
