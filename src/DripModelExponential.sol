// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {IDripModel} from "./interfaces/IDripModel.sol";
import {ExponentialDripLib} from "./lib/ExponentialDripLib.sol";

/**
 * @notice Exponential rate drip model.
 */
contract DripModelExponential is IDripModel {
  uint256 internal constant ONE_YEAR = 365.25 days;

  /// @notice Drip rate per-second.
  uint256 public immutable ratePerSecond;

  /// @param ratePerSecond_ Drip rate per-second.
  /// @dev For calculating the per-second drip rate, we use the exponential decay formula
  ///   A = P * (1 - r) ^ t
  /// where
  ///   A is final amount.
  ///   P is principal (starting) amount.
  ///   r is the per-second drip rate.
  ///   t is the number of elapsed seconds.
  /// For example, for an annual drip rate of 25%:
  ///   A = P * (1 - r) ^ t
  ///   0.75 = 1 * (1 - r) ^ 31557600
  ///   -r = 0.75^(1/31557600) - 1
  ///   -r = -9.116094732822280932149636651070655494101566187385032e-9
  /// Multiplying r by -1e18 to calculate the scaled up per-second value required by the constructor ~= 9116094774
  constructor(uint256 ratePerSecond_) {
    ratePerSecond = ratePerSecond_;
  }

  function dripFactor(uint256 lastDripTime_) external view returns (uint256) {
    uint256 timeSinceLastDrip_ = block.timestamp - lastDripTime_;
    if (timeSinceLastDrip_ == 0) return 0;
    return ExponentialDripLib.calculateDripFactor(ratePerSecond, timeSinceLastDrip_);
  }
}
