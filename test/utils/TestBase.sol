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

  function _randomBytes32() internal view returns (bytes32) {
    return keccak256(
      abi.encode(block.timestamp, blockhash(0), gasleft(), tx.origin, keccak256(msg.data), address(this).codehash)
    );
  }

  function _randomAddress() internal view returns (address payable) {
    return payable(address(uint160(_randomUint256())));
  }

  function _randomUint64() internal view returns (uint64) {
    return uint64(_randomUint256());
  }

  function _randomUint128() internal view returns (uint128) {
    return uint128(_randomUint256());
  }

  function _randomUint256() internal view returns (uint256) {
    return uint256(_randomBytes32());
  }
}
