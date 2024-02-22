// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IDripModel {
  /// @notice Returns the drip factor, the percentage of of some base amount (e.g. undripped rewards or reserve assets)
  /// which should drip, as a wad. For example, it there are 100 base amount assets and this method returns 1e17, then
  /// 100 * 1e17 / 1e18 = 10 assets will drip.
  /// @param lastDripTime_ Timestamp of the last drip
  function dripFactor(uint256 lastDripTime_) external view returns (uint256 dripFactor_);
}
