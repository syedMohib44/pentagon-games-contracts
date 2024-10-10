import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Fragments is ERC20 {
    uint256 immutable initialSupply = 0; //300 000 tokens

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) ERC20(_name, _symbol) {
        initialSupply = _initialSupply;
        _mint(msg.sender, _initialSupply);
    }
}