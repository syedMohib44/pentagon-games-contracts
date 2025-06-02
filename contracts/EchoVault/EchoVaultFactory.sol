// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../shared/BasicUpgradeableAccessControl.sol";
import "./EchoVaultProxy.sol";
import "./EchoVault.sol";

contract EchoVaultFactory is
    Initializable,
    UUPSUpgradeable,
    BasicUpgradeableAccessControl
{
    using SafeERC20 for IERC20;
    event Registered(address _owner, address token);

    address public PROXY_ADMIN;

    mapping(address => IERC20) public usersERC20;
    uint256 public fee = 10 * (10 ** 18);

    address public echoImplementation;

    function initialize(address _PROXY_ADMIN) public initializer {
        __Ownable_init(); // Initializes the Ownable contract
        __UUPSUpgradeable_init(); // Initializes the UUPS upgradeable contract
        PROXY_ADMIN = _PROXY_ADMIN;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    /**
     *  TOOD: Make Name and Symbol unique
     */
    function registerToken(
        string memory _name,
        string memory _symbol
    ) external payable {
        // require(msg.value == fee, "Invalid amount provided");

        // TODO: Put validation of Token and Name here.
        require(msg.sender != address(0), "Token already exists");

        // EchoVault echoVault = new EchoVault(_name, _symbol, fee, msg.sender);
        // Encode the initializer call
        bytes memory data = abi.encodeWithSelector(
            bytes4(keccak256("initialize(string,string,address)")),
            _name,
            _symbol,
            msg.sender
        );

        // Deploy the proxy
        EchoVaultProxy proxy = new EchoVaultProxy(
            echoImplementation, // your deployed EchoVault logic contract
            PROXY_ADMIN, // proxy admin (could be the factory, or a multisig)
            data // call initialize()
        );
        usersERC20[msg.sender] = IERC20(address(proxy));
        emit Registered(msg.sender, address(proxy));
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function setImplementation(address _echoImplementation) external onlyOwner {
        echoImplementation = _echoImplementation;
    }

    fallback() external payable {}

    receive() external payable {}
}
