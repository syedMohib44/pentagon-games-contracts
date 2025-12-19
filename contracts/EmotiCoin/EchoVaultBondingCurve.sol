// // SPDX-License-Identifier: MIT
// pragma solidity >=0.6.6;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// // ---------- INTERFACES ----------

// interface IERC20Mintable is IERC20 {
//     function mint(address to, uint256 amount) external;
//     function burn(uint256 amount) external; // Standard burn interface
// }

// interface IUniswapV2Router02_payable {
//     function factory() external pure returns (address);
//     function WETH() external pure returns (address);
//     function addLiquidityETH(
//         address token,
//         uint amountTokenDesired,
//         uint amountTokenMin,
//         uint amountETHMin,
//         address to,
//         uint deadline
//     ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
// }

// interface IUniswapV2Factory {
//     function getPair(address tokenA, address tokenB) external view returns (address pair);
// }

// interface ILPLocker {
//     function lock(address lpToken, uint256 amount, uint256 unlockTime, address owner) external;
// }

// // ============== PumpFunBondingCurve (Hyperbolic) ==============
// contract PumpFunBondingCurve is Ownable {

//     // ----------- Constants & Immutables -----------
//     uint256 public constant SCALE = 1e18; // Fixed-point math scale

//     IERC20Mintable public immutable TOKEN;
//     address public immutable feeTreasury;
//     address public immutable creator;

//     // --- Supply & Graduation Parameters ---
//     uint256 public immutable totalSupply;
//     uint256 public immutable curveSupply;     // 80% of total supply, held by this contract
//     uint256 public immutable graduationPC;    // PC raised to trigger graduation (e.g., 85e18)
//     uint256 public immutable tokensToBurn;    // Fixed amount of tokens to burn at graduation

//     // --- Hyperbolic Curve Parameters (from y = A - B / (C + x)) ---
//     uint256 private constant A = 1073000191000000000000000000;
//     uint256 private constant B = 321900057300000000000000000000;
//     uint256 private constant C = 30000000000000000000;

//     // ----------- Mutable Config (Owner-only) -----------
//     uint256 public feeBps;
//     IUniswapV2Router02_payable public router;
//     address public lpLocker;
//     uint256 public lpLockSeconds = 365 days;
//     address public pair;

//     // ----------- State -----------
//     uint256 public totalPCSpent; // Total PC spent on the curve (net of fees)
//     uint256 public tokensMinted; // Total tokens sold from the curve
//     bool public graduated;
//     uint256 private _locked = 1; // Reentrancy guard

//     // ----------- Events & Errors -----------
//     event Bought(address indexed buyer, uint256 pcIn, uint256 tokensOut);
//     event Graduated(uint256 pcToLP, uint256 tokensToLP, uint256 tokensBurned, address indexed pair);
//     event ConfigUpdated(address router, address locker, uint256 lockSeconds);
//     event FeeUpdated(uint256 newFeeBps);
//     error AlreadyGraduated();
//     error InvalidAmount();
//     error BadDecimals();
//     error Reentrancy();
//     error CurveDepleted();

//     // ----------- Modifiers -----------
//     modifier nonReentrant() {
//         if (_locked == 2) revert Reentrancy();
//         _locked = 2;
//         _;
//         _locked = 1;
//     }

//     // ----------- Constructor -----------
//     constructor(
//         address owner,
//         address _creator,
//         address _token,
//         address _feeTreasury,
//         uint256 _totalSupply,   // e.g., 1_000_000_000e18
//         uint256 _graduationPC,  // e.g., 85e18 for ~$69k market cap
//         uint256 _tokensToBurn,  // e.g., 930233e18
//         uint256 _feeBps         // e.g., 300 for 3%
//     ) {
//         _transferOwnership(owner);
//         creator = _creator;
//         TOKEN = IERC20Mintable(_token);
//         feeTreasury = _feeTreasury;

//         if (TOKEN.decimals() != 18) revert BadDecimals();
//         if (_feeBps > 1000) revert InvalidAmount();

//         totalSupply = _totalSupply;
//         curveSupply = (_totalSupply * 80) / 100; // 80% for the curve
//         graduationPC = _graduationPC;
//         tokensToBurn = _tokensToBurn;
//         feeBps = _feeBps;

//         // --- One-Step Launch: Mint and Distribute ---
//         TOKEN.mint(address(this), _totalSupply);
//         uint256 creatorAmount = (_totalSupply * 20) / 100; // 20% for the creator
//         TOKEN.transfer(_creator, creatorAmount);
//     }

//     // ----------- Admin Configuration -----------
//     function setRouterAndLocker(address _router, address _locker, uint256 _lockSeconds) external onlyOwner {
//         router = IUniswapV2Router02_payable(_router);
//         lpLocker = _locker;
//         lpLockSeconds = _lockSeconds;
//         emit ConfigUpdated(_router, _locker, _lockSeconds);
//     }

//     function setFeeBps(uint256 newFeeBps) external onlyOwner {
//         if (newFeeBps > 1000) revert InvalidAmount();
//         feeBps = newFeeBps;
//         emit FeeUpdated(newFeeBps);
//     }

//     // ----------- Public Buy -----------
//     function buy() external payable nonReentrant {
//         uint256 pcIn = msg.value;
//         if (graduated) revert AlreadyGraduated();
//         if (pcIn == 0) revert InvalidAmount();

//         uint256 fee = (pcIn * feeBps) / 10_000;
//         if (fee > 0) {
//             payable(feeTreasury).transfer(fee);
//         }
//         uint256 pcNet = pcIn - fee;

//         uint256 tokensOut = _getTokensForPC(pcNet);

//         if (tokensMinted + tokensOut > curveSupply) {
//             revert CurveDepleted();
//         }
//         tokensMinted += tokensOut;
//         totalPCSpent += pcNet;

//         TOKEN.transfer(msg.sender, tokensOut);
//         emit Bought(msg.sender, pcIn, tokensOut);

//         if (totalPCSpent >= graduationPC) {
//             _graduate();
//         }
//     }

//     // ----------- Graduation Logic -----------
//     function _graduate() internal {
//         graduated = true;

//         // 1. Burn Tokens from the contract's balance
//         TOKEN.burn(tokensToBurn);

//         // 2. Prepare for Liquidity
//         uint256 pcForLP = address(this).balance;
//         // Use the contract's entire remaining token balance for LP
//         uint256 tokenForLP = TOKEN.balanceOf(address(this));

//         // 3. Add Liquidity
//         TOKEN.approve(address(router), tokenForLP);
//         (, , uint256 lpAmount) = router.addLiquidityETH{value: pcForLP}(
//             address(TOKEN),
//             tokenForLP,
//             0, // amountTokenMin
//             0, // amountETHMin
//             address(this),
//             block.timestamp
//         );

//         // 4. Lock or Burn LP Tokens
//         address wpc = router.WETH();
//         address _pair = IUniswapV2Factory(router.factory()).getPair(address(TOKEN), wpc);
//         pair = _pair;

//         if (lpLocker != address(0)) {
//             IERC20(_pair).approve(lpLocker, lpAmount);
//             ILPLocker(lpLocker).lock(_pair, lpAmount, block.timestamp + lpLockSeconds, address(0));
//         } else {
//             IERC20(_pair).transfer(address(0xdead), lpAmount);
//         }

//         emit Graduated(pcForLP, tokenForLP, tokensToBurn, _pair);
//     }

//     // ----------- View Functions -----------
//     function quoteBuy(uint256 pcIn) external view returns (uint256 tokensOut) {
//         if (graduated || pcIn == 0) return 0;
//         uint256 pcNet = (pcIn * (10_000 - feeBps)) / 10_000;
//         tokensOut = _getTokensForPC(pcNet);
//         if (tokensMinted + tokensOut > curveSupply) {
//             tokensOut = curveSupply - tokensMinted;
//         }
//         return tokensOut;
//     }

//     // ----------- Math Helpers (Hyperbolic Curve) -----------
//     function _getTokensForPC(uint256 pcNet) internal view returns (uint256) {
//         uint256 currentTotalPC = totalPCSpent;
//         uint256 nextTotalPC = currentTotalPC + pcNet;

//         uint256 y_current_term = B / (C + currentTotalPC);
//         uint256 y_current = A - y_current_term;

//         uint256 y_next_term = B / (C + nextTotalPC);
//         uint256 y_next = A - y_next_term;
        
//         return (y_next - y_current) / SCALE;
//     }
// }
