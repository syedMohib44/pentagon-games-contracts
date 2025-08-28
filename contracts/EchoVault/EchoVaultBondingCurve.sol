// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ---------- Minimal Interfaces ----------
interface IERC20 {
    function transfer(address to, uint256 amt) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amt
    ) external returns (bool);

    function approve(address spender, uint256 amt) external returns (bool);

    function balanceOf(address a) external view returns (uint256);

    function decimals() external view returns (uint8);
}

interface IERC20Mintable is IERC20 {
    function mint(address to, uint256 amt) external;

    function burn(address from, uint256 amt) external;
}

// Uniswap V2–style router (PentaSwap on your chain)
interface IUniswapV2Router02 {
    function factory() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

// Optional LP locker interface (or set locker = address(0) to burn LP)
interface ILPLocker {
    function lock(
        address pair,
        address lpToken,
        uint256 amount,
        uint256 unlockTime,
        address owner
    ) external;
}

interface IUniswapV2FactoryLike {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address);
}

// ============== EchoVaultBondingCurve (power-law, p = 3) ==============
contract EchoVaultBondingCurve {
    // ----------- Constants / immutables -----------
    uint256 public constant SCALE = 1e18; // 60.18 fixed point for f

    IERC20Mintable public immutable TOKEN; // persona ERC20 (18 decimals recommended)
    IERC20 public immutable PC; // PC token (18 decimals)
    address public immutable feeTreasury;

    // Supply setup (recommend TOKEN has 18 decimals)
    uint256 public immutable totalSupply; // e.g., 100_000_000e18
    uint256 public immutable curveSupply; // 80% of total
    uint256 public immutable lpReserve; // 20% of total

    // Curve target (graduation): **250 PC** ≈ $5K
    uint256 public immutable targetPC; // e.g., 250e18

    // Creator enforced first buy (10 PC)
    uint256 public immutable creatorFirstBuy; // 10e18 PC

    // Fees on PC in (basis points)
    uint256 public feeBps; // e.g., 300 = 3%

    // Router / locker configuration
    IUniswapV2Router02 public router; // PentaSwap router
    address public lpLocker; // locker (or zero to burn LP)
    uint256 public lpLockSeconds = 365 days; // LP lock horizon
    address public pair; // cached pair address (optional)

    // ----------- State -----------
    uint256 public sold; // tokens emitted from curve
    uint256 public pcRaised; // net PC raised (after fee)
    uint256 public f; // fraction sold in 1e18 (f = sold/curveSupply * 1e18)
    bool public graduated;

    // Simple reentrancy guard
    uint256 private _locked;

    // ----------- Events -----------
    event Bought(
        address indexed buyer,
        uint256 pcIn,
        uint256 tokensOut,
        uint256 fAfter
    );
    event Graduated(
        uint256 pcToLP,
        uint256 tokensToLP,
        address pair,
        uint256 lpLockedOrBurned
    );
    event FeeUpdated(uint256 newFeeBps);
    event RouterUpdated(address router, address locker, uint256 lockSeconds);

    // ----------- Errors -----------
    error AlreadyGraduated();
    error NotGraduated();
    error InvalidAmount();
    error Slippage();
    error BadDecimals();
    error Reentrancy();

    modifier nonReentrant() {
        if (_locked == 1) revert Reentrancy();
        _locked = 1;
        _;
        _locked = 0;
    }

    constructor(
        address _token,
        address _pc,
        address _feeTreasury,
        uint256 _totalSupply, // e.g., 100_000_000e18
        uint256 _targetPC, // set to 250e18 for ~$5K graduation
        uint256 _creatorFirstBuy, // 10e18 PC
        uint256 _feeBps
    ) {
        TOKEN = IERC20Mintable(_token);
        PC = IERC20(_pc);
        feeTreasury = _feeTreasury;

        // strongly recommend 18 decimals for both
        if (TOKEN.decimals() != 18 || PC.decimals() != 18) revert BadDecimals();

        totalSupply = _totalSupply;
        curveSupply = (_totalSupply * 80) / 100; // 80%
        lpReserve = _totalSupply - curveSupply; // 20%
        targetPC = _targetPC; // 250e18 for $5K
        creatorFirstBuy = _creatorFirstBuy; // 10e18
        feeBps = _feeBps; // e.g., 300 = 3%
    }

    // ----------- Admin wiring for router/locker -----------
    function setRouterAndLocker(
        address _router,
        address _locker,
        uint256 _lockSeconds
    ) external {
        // add onlyOwner in production
        router = IUniswapV2Router02(_router);
        lpLocker = _locker;
        lpLockSeconds = _lockSeconds;
        emit RouterUpdated(_router, _locker, _lockSeconds);
    }

    function setFeeBps(uint256 newFeeBps) external {
        // add onlyOwner in production
        require(newFeeBps <= 1000, "fee too high"); // <=10%
        feeBps = newFeeBps;
        emit FeeUpdated(newFeeBps);
    }

    // ----------- Initialization -----------
    /// @notice Call after deploy; creator must approve 10 PC first.
    function initializePersona(address creator) external nonReentrant {
        require(sold == 0 && pcRaised == 0 && !graduated, "already initted");

        // Mint all supply to this contract.
        TOKEN.mint(address(this), totalSupply);

        // Force creator's first buy (10 PC)
        // Creator must have approved this contract to spend creatorFirstBuy PC.
        _buy(creator, creatorFirstBuy, 0);
    }

    // ----------- Public Buy -----------
    function buy(uint256 pcIn, uint256 minTokensOut) external nonReentrant {
        _buy(msg.sender, pcIn, minTokensOut);
    }

    // ----------- Core Buy Logic (p = 3 power curve) -----------
    function _buy(address to, uint256 pcIn, uint256 minTokensOut) internal {
        if (graduated) revert AlreadyGraduated();
        if (pcIn == 0) revert InvalidAmount();

        // Pull PC
        PC.transferFrom(msg.sender, address(this), pcIn);

        // Fee on PC in
        uint256 fee = (pcIn * feeBps) / 10_000;
        if (fee > 0) PC.transfer(feeTreasury, fee);
        uint256 pcNet = pcIn - fee;

        // C0 = R * f^3 / SCALE^2
        uint256 C0 = _cost(f);
        uint256 C1 = C0 + pcNet;

        // f1 = cbrt( C1 * SCALE^2 / R )
        uint256 f1 = _fractionAtCost(C1);
        if (f1 > SCALE) f1 = SCALE;

        // tokensOut = (f1 - f0) * curveSupply / SCALE
        uint256 deltaF = f1 - f;
        if (deltaF == 0) revert Slippage();
        uint256 tokensOut = (curveSupply * deltaF) / SCALE;

        // Cap in case of rounding
        if (sold + tokensOut > curveSupply) {
            tokensOut = curveSupply - sold;
        }

        // Deliver tokens immediately
        TOKEN.transfer(to, tokensOut);

        // Update state
        sold += tokensOut;
        pcRaised += pcNet;
        f = f1;

        emit Bought(to, pcIn, tokensOut, f1);

        // Auto-graduate
        if (pcRaised >= targetPC || sold == curveSupply) {
            _graduate();
        }
    }

    // ----------- Graduation: auto seed PentaSwap LP + lock/burn LP -----------
    function _graduate() internal {
        graduated = true;

        // PC side to LP (optionally subtract an ops cut here)
        uint256 pcBal = PC.balanceOf(address(this));
        uint256 pcForLP = pcBal;

        // Token side to LP: the pre-reserved 20% (still in this contract)
        uint256 tokenForLP = lpReserve;

        // Approvals
        TOKEN.approve(address(router), tokenForLP);
        PC.approve(address(router), pcForLP);

        // Add liquidity; receive LP at this contract
        (uint aTok, uint aPC, uint liq) = router.addLiquidity(
            address(TOKEN),
            address(PC),
            tokenForLP,
            pcForLP,
            0, // amountTokenMin
            0, // amountPCMin
            address(this), // receive LP here to lock/burn
            block.timestamp + 1800
        );

        // Get pair token
        address fac = router.factory();
        address _pair = IUniswapV2FactoryLike(fac).getPair(
            address(TOKEN),
            address(PC)
        );
        pair = _pair;
        IERC20 lp = IERC20(_pair);

        // Lock LP or burn
        if (lpLocker != address(0)) {
            lp.approve(lpLocker, liq);
            ILPLocker(lpLocker).lock(
                _pair,
                _pair,
                liq,
                block.timestamp + lpLockSeconds,
                address(0)
            );
        } else {
            lp.transfer(address(0xdead), liq);
        }

        emit Graduated(aPC, aTok, _pair, liq);
    }

    // ----------- Views -----------
    /// @notice Quote tokens for spending `pcIn` more at current state.
    function quoteBuy(uint256 pcIn) external view returns (uint256 tokensOut) {
        if (graduated || pcIn == 0) return 0;
        uint256 C0 = _cost(f);
        uint256 C1 = C0 + pcIn;
        uint256 f1 = _fractionAtCost(C1);
        if (f1 > SCALE) f1 = SCALE;
        uint256 deltaF = f1 - f;
        tokensOut = (curveSupply * deltaF) / SCALE;
        if (sold + tokensOut > curveSupply) {
            tokensOut = curveSupply - sold;
        }
    }

    /// @notice Current marginal price (PC per token) at fraction f.
    function price() external view returns (uint256 pcPerToken) {
        // price = (3 * R * f^2) / (curveSupply * SCALE)
        uint256 f2 = (f * f) / SCALE; // f^2 / 1e18
        uint256 num = 3 * targetPC * f2; // 3R * f^2
        pcPerToken = num / curveSupply; // /(curveSupply)
    }

    // ----------- Math: C(f) and inverse f(C) with p=3 -----------
    /// C(f) = R * f^3 / SCALE^2
    function _cost(uint256 f_) internal view returns (uint256) {
        uint256 f2 = (f_ * f_) / SCALE; // f^2 / 1e18
        uint256 f3 = (f2 * f_) / SCALE; // f^3 / 1e36
        return targetPC * f3; // PC in 1e18
    }

    /// f = cbrt( C * SCALE^2 / R )
    function _fractionAtCost(uint256 C) internal view returns (uint256) {
        // ratio = C * SCALE^2 / R (avoid overflow by stepwise mult/div)
        uint256 ratio = (C * SCALE) / 1; // C * 1e18
        ratio = (ratio * SCALE) / 1; // C * 1e36
        ratio = ratio / targetPC; // /R
        return _cbrtUD60x18(ratio);
    }

    /// Cube root for 60.18 scaled unsigned values (fast Newton iteration)
    function _cbrtUD60x18(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 g = _cbrtInitialGuess(x);
        unchecked {
            for (uint256 i = 0; i < 20; ++i) {
                uint256 g2 = (g * g) / SCALE;
                uint256 term = x / g2;
                uint256 next = (2 * g + term) / 3;
                if (next == g || next + 1 == g) break;
                g = next;
            }
        }
        return g;
    }

    function _cbrtInitialGuess(uint256 /*x*/) internal pure returns (uint256) {
        // Reasonable constant guess; Newton converges very fast.
        return 1e18;
    }
}
