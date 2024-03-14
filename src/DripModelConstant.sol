// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {Ownable} from "cozy-safety-module-shared/lib/Ownable.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {IDripModel} from "./interfaces/IDripModel.sol";

/**
 * @notice Constant rate drip model.
 */
contract DripModelConstant is IDripModel, Ownable {
  using FixedPointMathLib for uint256;

  /// @notice The amount to drip per-second.
  uint256 public amountPerSecond;

  /// @param owner_ The owner of the contract, allowed to update the `amountPerSecond` and transfer ownership.
  /// @param amountPerSecond_ The amount to drip per-second. This amount should be denoted in the same precision as the
  /// base amount that will be dripped.
  constructor(address owner_, uint256 amountPerSecond_) {
    __initOwnable(owner_);
    amountPerSecond = amountPerSecond_;
  }

  function updateAmountPerSecond(uint256 amountPerSecond_) external onlyOwner {
    amountPerSecond = amountPerSecond_;
  }

  function dripFactor(uint256 lastDripTime_, uint256 amount_) external view returns (uint256) {
    uint256 timeSinceLastDrip_ = block.timestamp - lastDripTime_;
    if (timeSinceLastDrip_ == 0 || amount_ == 0) return 0;

    // Calculate factor to multiply remaining_ by to get new amount after drip.
    return 1e18 - _differenceOrZero(amount_, amountPerSecond * timeSinceLastDrip_).divWadDown(amount_);
  }

  /// @dev Returns `x - y` if the result is positive, or zero if `x - y` would overflow and result in a negative value.
  function _differenceOrZero(uint256 x, uint256 y) internal pure returns (uint256 z) {
    unchecked {
      z = x >= y ? x - y : 0;
    }
  }
}
