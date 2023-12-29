// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {DripModelExponentialFactory} from "../src/DripModelExponentialFactory.sol";
import {DripModelExponential} from "../src/DripModelExponential.sol";
import {Create2} from "../src/lib/Create2.sol";
import "forge-std/Test.sol";

contract DripModelExponentialFactoryTest is Test, DripModelExponentialFactory {
  DripModelExponentialFactory factory;

  function setUp() public {
    factory = new DripModelExponentialFactory();
  }

  function test_deployModelAndVerifyAvailable() public {
    testFuzz_deployModelAndVerifyAvailable(100);
  }

  function testFuzz_deployModelAndVerifyAvailable(uint256 dripRatePerSecond_) public {
    dripRatePerSecond_ = bound(dripRatePerSecond_, 0, type(uint256).max);

    assertEq(factory.getModel(dripRatePerSecond_), address(0));

    bytes memory dripModelConstructorArgs_ = abi.encode(dripRatePerSecond_);

    address addr_ = Create2.computeCreate2Address(
      type(DripModelExponential).creationCode, dripModelConstructorArgs_, address(factory), keccak256("0")
    );

    vm.expectEmit(true, false, false, true);
    emit DeployedDripModelExponential(addr_, dripRatePerSecond_);
    address _result = address(factory.deployModel(dripRatePerSecond_));
    assertEq(_result, factory.getModel(dripRatePerSecond_));

    // Trying to deploy again should result in revert
    vm.expectRevert();
    factory.deployModel(dripRatePerSecond_);
  }
}
