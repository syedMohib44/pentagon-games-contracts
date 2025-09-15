// Hypebolic law

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


interface IEchoVault is IERC20 {
    function burn(uint256 amount) external;
}

interface IPentaswapV2Router02_payable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IPentaswapV2Factory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface ILPLocker {
    function lock(
        address lpToken,
        uint256 amount,
        uint256 unlockTime,
        address owner
    ) external;
}

contract PumpFunBondingCurve is Ownable, ReentrancyGuard {
    IEchoVault public immutable TOKEN;
    address public immutable feeTreasury;
    address public immutable creator;

    uint256 public immutable totalSupply;
    uint256 public immutable curveSupply;
    uint256 public immutable graduationPC;
    uint256 public immutable tokensToBurn;

    uint256 public feeBps;
    IPentaswapV2Router02_payable public router;
    address public lpLocker;
    uint256 public lpLockSeconds = 365 days;
    address public pair;

    uint256 public virtualTokenReserves;
    uint256 public virtualPCReserves;
    uint256 public realTokenReserves; // Equivalent to tokensMinted
    uint256 public realPCReserves; // Equivalent to totalPCSpent
    bool public graduated;

    event Bought(address indexed buyer, uint256 pcIn, uint256 tokensOut);
    event Graduated(
        uint256 pcToLP,
        uint256 tokensToLP,
        uint256 tokensBurned,
        address indexed pair
    );
    event ConfigUpdated(address router, address locker, uint256 lockSeconds);
    event FeeUpdated(uint256 newFeeBps);
    error AlreadyGraduated();
    error InvalidAmount();
    error CurveDepleted();

    constructor(
        address owner,
        address _creator,
        address _token,
        address _feeTreasury,
        uint256 _totalSupply,
        uint256 _graduationPC,
        uint256 _tokensToBurn,
        uint256 _feeBps,
        uint256 _initialVirtualTokenReserves,
        uint256 _initialVirtualPCReserves,
        address _router,
        address _lpLocker,
        uint256 _lpLockSeconds
    ) {
        _transferOwnership(owner);
        creator = _creator;
        TOKEN = IEchoVault(_token);
        feeTreasury = _feeTreasury;

        if (_feeBps > 1000) revert InvalidAmount();

        totalSupply = _totalSupply;
        curveSupply = (_totalSupply * 60) / 100;
        graduationPC = _graduationPC;
        tokensToBurn = _tokensToBurn;
        feeBps = _feeBps;

        virtualTokenReserves = _initialVirtualTokenReserves;
        virtualPCReserves = _initialVirtualPCReserves;
        realTokenReserves = curveSupply; // Start with all curve tokens as real reserves

        router = IPentaswapV2Router02_payable(_router);
        lpLocker = _locker;
        lpLockSeconds = _lockSeconds;

        // TOKEN.mint(address(this), _totalSupply);
        // uint256 creatorAmount = (_totalSupply * 20) / 100;
        // TOKEN.transfer(_creator, creatorAmount);
    }

    // function setRouterAndLocker(
    //     address _router,
    //     address _locker,
    //     uint256 _lockSeconds
    // ) external onlyOwner {
    //     router = IPentaswapV2Router02_payable(_router);
    //     lpLocker = _locker;
    //     lpLockSeconds = _lockSeconds;
    //     emit ConfigUpdated(_router, _locker, _lockSeconds);
    // }

    function setFeeBps(uint256 newFeeBps) external onlyOwner {
        if (newFeeBps > 1000) revert InvalidAmount();
        feeBps = newFeeBps;
        emit FeeUpdated(newFeeBps);
    }

    function buy() external payable nonReentrant {
        uint256 pcIn = msg.value;
        if (graduated) revert AlreadyGraduated();
        if (pcIn == 0) revert InvalidAmount();

        uint256 fee = (pcIn * feeBps) / 10_000;
        if (fee > 0) {
            payable(feeTreasury).transfer(fee);
        }
        uint256 pcNet = pcIn - fee;

        // --- AMM Math: x * y = k ---
        uint256 tokensOut = _getTokensForPC(pcNet);

        if (tokensOut > realTokenReserves) {
            revert CurveDepleted();
        }

        // --- Update Reserves ---
        virtualPCReserves += pcNet;
        virtualTokenReserves -= tokensOut;
        realPCReserves += pcNet;
        realTokenReserves -= tokensOut;

        TOKEN.transfer(msg.sender, tokensOut);
        emit Bought(msg.sender, pcIn, tokensOut);

        if (realPCReserves >= graduationPC) {
            _graduate();
        }
    }

    function _graduate() internal {
        graduated = true;
        TOKEN.burn(tokensToBurn);
        uint256 pcForLP = address(this).balance;
        uint256 tokenForLP = TOKEN.balanceOf(address(this));

        TOKEN.approve(address(router), tokenForLP);
        (, , uint256 lpAmount) = router.addLiquidityETH{value: pcForLP}(
            address(TOKEN),
            tokenForLP,
            0,
            0,
            address(this),
            block.timestamp
        );

        address wpc = router.WETH();
        address _pair = IPentaswapV2Factory(router.factory()).getPair(
            address(TOKEN),
            wpc
        );
        pair = _pair;

        if (lpLocker != address(0)) {
            IERC20(_pair).approve(lpLocker, lpAmount);
            ILPLocker(lpLocker).lock(
                _pair,
                lpAmount,
                block.timestamp + lpLockSeconds,
                address(0)
            );
        } else {
            IERC20(_pair).transfer(address(0xdead), lpAmount);
        }

        emit Graduated(pcForLP, tokenForLP, tokensToBurn, _pair);
    }

    function quoteBuy(uint256 pcIn) external view returns (uint256 tokensOut) {
        if (graduated || pcIn == 0) return 0;
        uint256 pcNet = (pcIn * (10_000 - feeBps)) / 10_000;
        tokensOut = _getTokensForPC(pcNet);
        return Math.min(tokensOut, realTokenReserves);
    }

    function _getTokensForPC(uint256 pcAmount) internal view returns (uint256) {
        if (pcAmount == 0) return 0;
        // Using 128-bit integers for intermediate calculations to prevent overflow
        uint256 k = uint256(virtualPCReserves) * uint256(virtualTokenReserves);
        uint256 newVirtualPCReserves = virtualPCReserves + pcAmount;
        uint256 newVirtualTokenReserves = k / newVirtualPCReserves;

        // The +1 in the Rust code is a common trick to handle rounding in integer division.
        // Solidity's integer division truncates, so we don't need it here.
        // The difference is the amount of tokens out.
        return virtualTokenReserves - newVirtualTokenReserves;
    }
}
