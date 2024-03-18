// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {MathConstants} from "cozy-safety-module-shared/lib/MathConstants.sol";
import {Ownable} from "cozy-safety-module-shared/lib/Ownable.sol";
import {IDripModel} from "cozy-safety-module-shared/interfaces/IDripModel.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

/**
 * @notice Constant rate drip model.
 */
contract DripModelConstant is Ownable, IDripModel {
  using FixedPointMathLib for uint256;

  /// @notice The amount to drip per-second.
  uint256 public amountPerSecond;

  event AmountPerSecondUpdated(uint256 oldAmountPerSecond, uint256 newAmountPerSecond);

  /// @param owner_ The owner of the contract, allowed to update the `amountPerSecond` and transfer ownership.
  /// @param amountPerSecond_ The amount to drip per-second. This amount should be denoted in the same precision as the
  /// base amount that will be dripped.
  constructor(address owner_, uint256 amountPerSecond_) {
    __initOwnable(owner_);
    amountPerSecond = amountPerSecond_;
  }

  /// @param amountPerSecond_ The amount to drip per-second. This amount should be denoted in the same precision as the
  /// base amount that will be dripped.
  function updateAmountPerSecond(uint256 amountPerSecond_) external onlyOwner {
    emit AmountPerSecondUpdated(amountPerSecond, amountPerSecond_);
    amountPerSecond = amountPerSecond_;
  }

  /// @notice Returns the drip factor, which is the factor to multiply the initial amount by to get the amount to drip.
  /// @param lastDripTime_ The last time the drip was called.
  /// @param initialAmount_ The initial amount to drip from.
  function dripFactor(uint256 lastDripTime_, uint256 initialAmount_) external view returns (uint256) {
    uint256 timeSinceLastDrip_ = block.timestamp - lastDripTime_;
    if (timeSinceLastDrip_ == 0 || initialAmount_ == 0) return 0;

    // Calculate factor to multiply initialAmount_ by to get the amount to drip.
    // The result of division is rounded up to favor a smaller drip factor.
    return MathConstants.WAD
      - _differenceOrZero(initialAmount_, amountPerSecond * timeSinceLastDrip_).divWadUp(initialAmount_);
  }

  /// @dev Returns `x - y` if the result is positive, or zero if `x - y` would overflow and result in a negative value.
  function _differenceOrZero(uint256 x, uint256 y) internal pure returns (uint256 z) {
    unchecked {
      z = x >= y ? x - y : 0;
    }
  }
}
