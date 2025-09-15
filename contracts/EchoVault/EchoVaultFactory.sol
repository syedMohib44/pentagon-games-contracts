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
    mapping(string => address) public usersSymbol;
    mapping(string => address) public usersName;

    uint256 public fee = 10 * (10 ** 18);

    address public echoImplementation;
    address public router;
    address public locker;
    uint256 public lockSeconds = 600;

    IImplementationApprovalRegistry public implementationApprovalRegistry;

    function initialize(
        address _PROXY_ADMIN,
        address _implementationApprovalRegistry,
        address _router,
        address _locker
    ) public initializer {
        __Ownable_init(); // Initializes the Ownable contract
        __UUPSUpgradeable_init(); // Initializes the UUPS upgradeable contract
        PROXY_ADMIN = _PROXY_ADMIN;
        implementationApprovalRegistry = IImplementationApprovalRegistry(
            _implementationApprovalRegistry
        );
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
        require(msg.sender != address(0), "Token already exists");

        require(
            bytes(_name).length != 0 && bytes(_symbol).length != 0,
            "Name or Symbol is invalid"
        );

        require(
            address(usersERC20[msg.sender]) == address(0),
            "User already registered"
        );

        require(usersSymbol[_symbol] == address(0), "Symbol already taken");
        require(usersName[_name] == address(0), "Name already taken");
        require(
            address(implementationApprovalRegistry) != address(0),
            "Implementation should not be null address"
        );

        // Encode the initializer call
        bytes memory data = abi.encodeWithSelector(
            bytes4(
                keccak256(
                    "initialize(string,string,address,address,address,address,uint256)"
                )
            ),
            _name,
            _symbol,
            msg.sender,
            address(implementationApprovalRegistry),
            router,
            locker,
            lockSeconds
        );

        require(
            implementationApprovalRegistry.approvedImplementation(
                echoImplementation
            ),
            "Implementation not approved"
        );

        // Deploy the proxy
        EchoVaultProxy proxy = new EchoVaultProxy(
            echoImplementation, // your deployed EchoVault logic contract
            PROXY_ADMIN, // proxy admin (could be the factory, or a multisig)
            data // call initialize()
        );

        usersERC20[msg.sender] = IERC20(address(proxy));
        usersSymbol[_symbol] = msg.sender;
        usersName[_name] = msg.sender;

        emit Registered(msg.sender, address(proxy));
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function setImplementation(address _echoImplementation) external onlyOwner {
        echoImplementation = _echoImplementation;
    }

    function setRouterAndLocker(
        address _router,
        address _locker,
        uint256 _lockSeconds
    ) external onlyOwner {
        router = IPentaswapV2Router02_payable(_router);
        lpLocker = _locker;
        lpLockSeconds = _lockSeconds;
        emit ConfigUpdated(_router, _locker, _lockSeconds);
    }

    function setImplementationApprovalRegistry(
        address _implementationApprovalRegistry
    ) external onlyOwner {
        implementationApprovalRegistry = IImplementationApprovalRegistry(
            _implementationApprovalRegistry
        );
    }

    fallback() external payable {}

    receive() external payable {}
}
