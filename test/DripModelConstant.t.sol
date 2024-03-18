// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {MathConstants} from "cozy-safety-module-shared/lib/MathConstants.sol";
import {DripModelConstant} from "../src/DripModelConstant.sol";
import {TestBase} from "./utils/TestBase.sol";

contract DripModelExponentialTest is TestBase {
  DripModelConstant model;
  address owner = address(0xBEEF);

  event AmountPerSecondUpdated(uint256 oldAmountPerSecond, uint256 newAmountPerSecond);

  constructor() {
    model = new DripModelConstant(owner, 100);
  }

  function testFuzz_zeroTimeSinceLastDripOrZeroInitialAmount(uint256 rate_) public {
    model = new DripModelConstant(owner, rate_);

    assertEq(
      model.dripFactor(block.timestamp, _randomUint256()), 0, "dripFactor should be 0 when timeSinceLastDrip is 0"
    );

    uint256 currentTime_ = bound(_randomUint256(), 1, type(uint256).max);
    vm.warp(currentTime_);

    assertEq(
      model.dripFactor(bound(_randomUint256(), 0, currentTime_), 0), 0, "dripFactor should be 0 when initialAmount is 0"
    );
  }

  function testFuzz_initialAmountLessThanAmountPerSecond(uint128 rate_) public {
    vm.assume(rate_ > 1);
    model = new DripModelConstant(owner, rate_);

    vm.warp(block.timestamp + _randomUint64());

    // If initialAmount_ is 0, dripFactor returns 0.
    uint256 initialAmount_ = bound(_randomUint128(), 1, rate_);

    assertEq(
      model.dripFactor(block.timestamp - 1, initialAmount_),
      MathConstants.WAD,
      "dripFactor should be 1e18 when initialAmount is lte amountPerSecond"
    );
  }

  function test_updateAmountPerSecond(uint256 rate_) public {
    vm.prank(owner);
    _expectEmit();
    emit AmountPerSecondUpdated(100, rate_);
    model.updateAmountPerSecond(rate_);

    assertEq(model.amountPerSecond(), rate_, "amountPerSecond should be updated");
  }

  function test_zeroAmountPerSecond() external {
    model = new DripModelConstant(owner, 0);
    vm.warp(block.timestamp + _randomUint64());
    assertEq(
      model.dripFactor(bound(_randomUint64(), 0, block.timestamp - 1), _randomUint128()),
      0,
      "dripFactor should be 0 when amountPerSecond is 0"
    );
  }

  function testFuzz_dripFactorLessOrEqualTo100Rate(uint64 amountPerSecond_, uint64 currentTime_, uint128 initialAmount_)
    external
  {
    vm.assume(currentTime_ > 0);
    model = new DripModelConstant(owner, amountPerSecond_);
    vm.warp(currentTime_);

    uint256 dripFactor_ = model.dripFactor(bound(_randomUint64(), 0, currentTime_ - 1), initialAmount_);
    assertLe(dripFactor_, MathConstants.WAD, "dripFactor should be less or equal to 1e18");
  }

  function test_concreteDripFactor() external {
    uint256 currentTime_ = 100;
    vm.warp(currentTime_);

    uint256 dripFactor_ = model.dripFactor(currentTime_ - 1, 50);
    assertEq(dripFactor_, MathConstants.WAD, "dripFactor should be 1e18 when initial amount < amountPerSecond");

    dripFactor_ = model.dripFactor(currentTime_ - 1, 100);
    assertEq(dripFactor_, MathConstants.WAD, "dripFactor should be 1e18");

    dripFactor_ = model.dripFactor(currentTime_ - 1, 200);
    assertEq(dripFactor_, 0.5e18, "dripFactor should be 0.5e18");

    dripFactor_ = model.dripFactor(currentTime_ - 1, 500);
    assertEq(dripFactor_, 0.2e18, "dripFactor should be 0.2e18");

    dripFactor_ = model.dripFactor(currentTime_ - 1, 1000);
    assertEq(dripFactor_, 0.1e18, "dripFactor should be 0.1e18");

    dripFactor_ = model.dripFactor(currentTime_ - 2, 100);
    assertEq(dripFactor_, MathConstants.WAD, "dripFactor should be 1e18 when initial amount < amountPerSecond");

    dripFactor_ = model.dripFactor(currentTime_ - 2, 200);
    assertEq(dripFactor_, 1e18, "dripFactor should be 1e18");

    dripFactor_ = model.dripFactor(currentTime_ - 2, 400);
    assertEq(dripFactor_, 0.5e18, "dripFactor should be 0.5e18");

    dripFactor_ = model.dripFactor(currentTime_ - 2, 800);
    assertEq(dripFactor_, 0.25e18, "dripFactor should be 0.25e18");

    dripFactor_ = model.dripFactor(currentTime_ - 2, 1000);
    assertEq(dripFactor_, 0.2e18, "dripFactor should be 0.2e18");

    dripFactor_ = model.dripFactor(currentTime_ - 1, 1000e18);
    assertEq(dripFactor_, 0, "dripFactor should be 0, because rounding favors dripping less assets than more");
  }
}
