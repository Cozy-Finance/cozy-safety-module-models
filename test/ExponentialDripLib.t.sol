// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {ExponentialDripLib} from "../src/lib/ExponentialDripLib.sol";
import {TestBase} from "./utils/TestBase.sol";

contract ExponentialDripLibUnitTest is TestBase {
  function test_exponentialDripFactor_Seconds() external {
    uint256 rate_ = 0.25e18; // 25% drip rate per second

    // Compounds over 1 period
    assertEq(ExponentialDripLib.calculateDripFactor(rate_, 1), 250_000_000_000_000_000);
    // Compounds over 2 periods
    assertEq(ExponentialDripLib.calculateDripFactor(rate_, 2), 437_500_000_000_000_000);
    // Compounds over 3 periods
    assertEq(ExponentialDripLib.calculateDripFactor(rate_, 3), 578_125_000_000_000_000);
  }

  function test_exponentialDripFactor_Years() external {
    uint256 rate_ = 9_116_094_774; // 25% drip rate per year

    // Compounds over 1 period
    assertEq(ExponentialDripLib.calculateDripFactor(rate_, ONE_YEAR), 250_000_000_976_866_966);
    // Compounds over 2 periods
    assertEq(ExponentialDripLib.calculateDripFactor(rate_, 2 * ONE_YEAR), 437_500_001_465_300_445);
    // Compounds over 3 periods
    assertEq(ExponentialDripLib.calculateDripFactor(rate_, 3 * ONE_YEAR), 578_125_001_648_463_000);
  }

  function test_exponentialDripFactor_ZeroTimeDelta() external {
    uint256 rate_ = 250_000_000_000_000_000; // 25% drip rate per second
    // mulDivDown with a denominator of 0 results in 0
    assertEq(ExponentialDripLib.calculateDripFactor(rate_, 0), 0);
  }

  function test_exponentialDripFactor_ZeroDripRate() external {
    uint256 rate_ = 0; // 0% drip
    // mulDivDown with a denominator of 0 results in 0
    assertEq(ExponentialDripLib.calculateDripFactor(rate_, 1), 0);
  }

  function test_exponentialDripFactor_100Rate() external {
    uint256 rate_ = 1e18; // 100% drip
    assertEq(ExponentialDripLib.calculateDripFactor(rate_, 1), 1e18);
  }

  function test_exponentialDripFactor_101RateReverts() external {
    uint256 rate_ = 1e18 + 1;
    _expectPanic(PANIC_MATH_UNDEROVERFLOW);
    ExponentialDripLib.calculateDripFactor(rate_, 1);
  }

  function testFuzz_exponentialDripFactor_LessOrEqualThan100Rate(uint256 rate_) external {
    rate_ = bound(rate_, 1, 1e18 - 1);
    assertLe(ExponentialDripLib.calculateDripFactor(rate_, 1), 1e18);
  }
}
