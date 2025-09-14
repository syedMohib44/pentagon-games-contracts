// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

/**
 * @title PumpFunBondingCurve (Stateless Logic Contract)
 * @notice This is a stateless "calculator" contract. It holds no funds or data.
 * The EchoVault contract calls this contract to perform bonding curve math.
 * All constants for the sale are defined here for consistency.
 */
contract PumpFunBondingCurve {
    // ----------- Constants -----------
    // These public constants are accessed by the EchoVault contract.
    uint256 public constant SCALE = 1e18;
    uint256 public constant MAX_SUPPLY = 100_000_000 * 1e18;
    uint256 public constant CURVE_SUPPLY = (MAX_SUPPLY * 80) / 100;
    uint256 public constant TARGET_PC = 250 * 1e18;
    uint256 public constant TOKENS_TO_BURN = 930233 * 1e18;
    uint256 public constant FEE_BPS = 300;

    constructor() {}

    // ----------- Pure Calculation Functions -----------

    /**
     * @notice Calculates the result of a buy transaction without changing state.
     * @param pcIn The amount of PC being spent by the user.
     * @param currentSold The current number of tokens sold on the curve.
     * @param currentPcRaised The current amount of PC raised.
     * @param currentF The current fraction of the curve that is filled.
     * @return tokensOut The number of tokens the user should receive.
     * @return newSold The updated number of tokens sold.
     * @return newPcRaised The updated amount of PC raised.
     * @return newF The updated fraction of the curve filled.
     */
    function calculateBuy(
        uint256 pcIn,
        uint256 currentSold,
        uint256 currentPcRaised,
        uint256 currentF
    )
        external
        pure
        returns (
            uint256 tokensOut,
            uint256 newSold,
            uint256 newPcRaised,
            uint256 newF
        )
    {
        if (pcIn == 0) return (0, currentSold, currentPcRaised, currentF);

        uint256 pcNet = (pcIn * (10000 - FEE_BPS)) / 10000;

        uint256 C0 = _cost(currentF);
        uint256 C1 = C0 + pcNet;
        newF = _fractionAtCost(C1);
        if (newF > SCALE) newF = SCALE;

        tokensOut = (CURVE_SUPPLY * (newF - currentF)) / SCALE;
        if (currentSold + tokensOut > CURVE_SUPPLY) {
            tokensOut = CURVE_SUPPLY - currentSold;
        }

        newSold = currentSold + tokensOut;
        newPcRaised = currentPcRaised + pcNet;

        return (tokensOut, newSold, newPcRaised, newF);
    }

    // --- Math Helpers (Cubic Curve) ---
    function _cost(uint256 f_) internal pure returns (uint256) {
        uint256 f2_scaled = (f_ * f_) / SCALE;
        uint256 f3_scaled = (f2_scaled * f_) / SCALE;
        return (TARGET_PC * f3_scaled) / SCALE;
    }

    function _fractionAtCost(uint256 C) internal pure returns (uint256) {
        if (C == 0) return 0;
        uint256 ratio = (C * SCALE) / TARGET_PC;
        return _cbrt(ratio);
    }

    function _cbrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = x;
        uint256 result;
        for (uint i = 0; i < 100; i++) {
            result = z;
            z = (x / (z * z) + 2 * z) / 3;
            if (z == result) break;
        }
        return result;
    }
}
