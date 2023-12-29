// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {DripModelExponential} from "../src/DripModelExponential.sol";
import {ExponentialDripLib} from "../src/lib/ExponentialDripLib.sol";
import "forge-std/Test.sol";

contract DripModelExponentialFactoryTest is Test {
  function testFuzz_DripModelMatchesLibOutput(uint256 rate_, uint256 lastDripTime_, uint256 timeSinceLastDrip_) public {
    rate_ = bound(rate_, 1, 1e18 - 1);
    DripModelExponential model = new DripModelExponential(rate_);

    assertEq(model.ratePerSecond(), rate_);
    assertEq(
      model.dripFactor(lastDripTime_, timeSinceLastDrip_),
      ExponentialDripLib.calculateDripFactor(rate_, timeSinceLastDrip_)
    );
  }
}
