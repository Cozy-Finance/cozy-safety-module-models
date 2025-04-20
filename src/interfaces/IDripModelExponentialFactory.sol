// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IDripModel} from "cozy-safety-module-libs/interfaces/IDripModel.sol";

interface IDripModelExponentialFactory {
  /// @notice Deploys a DripModelExponential contract and emits a DeployedDripModelExponential event that
  /// indicates what the params from the deployment are. This address is then cached inside the
  /// isDeployed mapping.
  /// @return model_ which has an address that is deterministic with the input ratePerSecond_.
  function deployModel(uint256 ratePerSecond_) external returns (IDripModel model_);

  /// @return The address where the model is deployed, or address(0) if it isn't deployed.
  function getModel(uint256 ratePerSecond_) external view returns (address);
}
