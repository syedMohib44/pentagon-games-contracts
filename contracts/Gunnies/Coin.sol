import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../shared/BasicAccessControl.sol";
import "../shared/Freezable.sol";

contract Coin is
    ERC20,
    ERC20Burnable,
    ERC20Permit,
    Freezable,
    BasicAccessControl
{
    event Spend(address from, address to, uint256 amount);
    event Claim(address from, address to, uint256 amount);

    mapping(address => bool) public transferable;
    bool public isTransferable = false;
    mapping(address => bool) public whitelisted;

    constructor() ERC20("Coin", "COIN") ERC20Permit("Coin") {}

    function mint(address _to, uint256 _amount) external onlyModerators {
        _mint(_to, _amount);
    }

    function bulkMint(
        address[] memory _to,
        uint256[] memory _amount
    ) external onlyModerators {
        for (uint256 index = 0; index < _to.length; index++) {
            _mint(_to[index], _amount[index]);
        }
    }

    function claim(uint256 _amount) external {
        require(msg.sender != address(0), "Cannot claim to null address");
        require(whitelisted[msg.sender] == true, "Player is not whitelisted");
        _mint(msg.sender, _amount);
        emit Claim(msg.sender, address(this), _amount);
    }

    function spend(address _to, uint256 _amount) external {
        require(whitelisted[msg.sender] == true, "Player is not whitelisted");
        super.transfer(_to, _amount);
        emit Spend(msg.sender, _to, _amount);
    }

    function toggleWhitelist(address _address) external onlyModerators {
        require(_address != address(0), "Cannot toggle null address");
        whitelisted[_address] = !whitelisted[_address];
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
