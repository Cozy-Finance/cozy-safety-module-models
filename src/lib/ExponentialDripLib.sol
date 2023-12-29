// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {wadLn, wadExp} from "solmate/utils/SignedWadMath.sol";

library ExponentialDripLib {
  using FixedPointMathLib for uint256;

  uint256 constant MAX_INT256 = uint256(type(int256).max);

  /// @dev Calculate the exponential drip rate, according to
  ///   A = P * (1 - r) ^ t
  /// where:
  ///   A is final amount.
  ///   P is principal (starting) amount.
  ///   r is the per-second drip rate.
  ///   t is the number of elapsed seconds.
  /// A and p should be expressed as 18 decimal numbers, e.g to calculate the
  /// @param a_ 18 decimal precision uint256 expressing the final amount.
  /// @param p_ 18 decimal precision uint256 expressing the principal.
  /// @param t_ uint256 expressing the time in seconds.
  /// @return r_ 18 decimal precision uint256 expressing the drip rate in seconds.
  function calculateDripRate(uint256 a_, uint256 p_, uint256 t_) internal pure returns (uint256 r_) {
    require(a_ <= p_, "Final amount must be less than or equal to principal.");
    require(a_ <= MAX_INT256, "_a must be smaller than type(int256).max");
    require(p_ <= MAX_INT256, "_p must be smaller than type(int256).max");
    require(t_ <= MAX_INT256, "_t must be smaller than type(int256).max");

    // Let 1 - r = x, then (ln(A) - ln(p))/t = ln(x)
    int256 lnX_ = (wadLn(int256(a_)) - wadLn(int256(p_))) / int256(t_);
    int256 x_ = wadExp(lnX_);
    require(x_ >= 0, "_x must be >= 0");
    r_ = 1e18 - uint256(x_);
  }

  /// @notice Calculates the exponential drip factor given r (as a WAD) and t. This is based off the exponential decay
  /// formula A = P * (1 - r) ^ t, and computes the factor (1 - r) ^ t.
  function calculateDripFactor(uint256 rWad_, uint256 t_) internal pure returns (uint256) {
    // A is calculated and subtracted from 1e18 (i.e. 100%) to calculate the factor of the some asset pool that has
    // dripped, e.g. if A = 0.75e18 this would mean there was a 0.25e18 (i.e. 25%) drip rate -- hence the subtraction.
    return 1e18 - (1e18 - rWad_).rpow(t_, 1e18);
  }
}
