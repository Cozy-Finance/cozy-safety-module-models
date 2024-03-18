// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {DripModelExponential} from "../src/DripModelExponential.sol";
import {ExponentialDripLib} from "../src/lib/ExponentialDripLib.sol";
import {TestBase} from "./utils/TestBase.sol";

contract DripModelExponentialTest is TestBase {
  function testFuzz_DripModelMatchesLibOutput(uint256 rate_, uint256 lastDripTime_) public {
    rate_ = bound(rate_, 1, 1e18 - 1);
    lastDripTime_ = bound(lastDripTime_, 0, block.timestamp);
    DripModelExponential model = new DripModelExponential(rate_);

    assertEq(model.ratePerSecond(), rate_);
    assertEq(
      model.dripFactor(lastDripTime_, _randomUint256()),
      ExponentialDripLib.calculateDripFactor(rate_, block.timestamp - lastDripTime_)
    );
  }

  function testFuzz_ZeroTimeSinceLastDrip(uint256 rate_) public {
    DripModelExponential model = new DripModelExponential(rate_);
    assertEq(model.dripFactor(block.timestamp, _randomUint256()), 0);
  }
}
