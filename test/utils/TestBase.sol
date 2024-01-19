// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {Test} from "forge-std/Test.sol";

contract TestBase is Test {
  uint256 internal constant PANIC_MATH_UNDEROVERFLOW = 0x11;

  bytes4 internal constant PANIC_SELECTOR = bytes4(keccak256("Panic(uint256)"));

  uint64 constant ONE_YEAR = 365.25 days;

  function _expectEmit() internal {
    vm.expectEmit(true, true, true, true);
  }

  function _expectPanic(uint256 code_) internal {
    vm.expectRevert(abi.encodeWithSelector(PANIC_SELECTOR, code_));
  }
}
