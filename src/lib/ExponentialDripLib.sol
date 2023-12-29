// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

library ExponentialDripLib {
  using FixedPointMathLib for uint256;

  /// @notice Calculates the exponential drip factor given r (as a WAD) and t. This is based off the exponential decay
  /// formula A = P * (1 - r) ^ t, and computes the factor (1 - r) ^ t.
  function calculateDripFactor(uint256 rWad_, uint256 t_) internal pure returns (uint256) {
    // A is calculated and subtracted from 1e18 (i.e. 100%) to calculate the factor of the some asset pool that has
    // dripped, e.g. if A = 0.75e18 this would mean there was a 0.25e18 (i.e. 25%) drip rate -- hence the subtraction.
    return 1e18 - (1e18 - rWad_).rpow(t_, 1e18);
  }
}
