// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {DripModelConstantFactory} from "../src/DripModelConstantFactory.sol";
import {DripModelConstant} from "../src/DripModelConstant.sol";
import {Create2} from "../src/lib/Create2.sol";
import {TestBase} from "./utils/TestBase.sol";

contract DripModelConstantFactoryTest is TestBase, DripModelConstantFactory {
  DripModelConstantFactory factory;

  function setUp() public {
    factory = new DripModelConstantFactory();
  }

  function test_deployModel() public {
    address caller_ = _randomAddress();
    address owner_ = _randomAddress();
    bytes32 baseSalt_ = _randomBytes32();
    testFuzz_deployModel(caller_, owner_, 100, baseSalt_);
  }

  function testFuzz_deployModel(address caller_, address owner_, uint256 amountPerSecond_, bytes32 baseSalt_) public {
    amountPerSecond_ = bound(amountPerSecond_, 0, type(uint256).max);

    address expectedAddr_ = factory.computeAddress(caller_, owner_, amountPerSecond_, baseSalt_);

    _expectEmit();
    emit DeployedDripModelConstant(expectedAddr_, owner_, amountPerSecond_);
    vm.prank(caller_);
    DripModelConstant model_ = DripModelConstant(address(factory.deployModel(owner_, amountPerSecond_, baseSalt_)));
    assertEq(address(model_), expectedAddr_, "deployModel should return the expected address");
    assertEq(model_.owner(), owner_, "owner should be set");
    assertEq(model_.amountPerSecond(), amountPerSecond_, "amountPerSecond should be set");
  }
}
