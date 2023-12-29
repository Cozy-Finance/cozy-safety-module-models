// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {DripModelExponential} from "./DripModelExponential.sol";
import {BaseModelFactory} from "./abstract/BaseModelFactory.sol";
import {Create2} from "./lib/Create2.sol";

/**
 * @notice The factory for deploying a DripModelExponential contract.
 */
contract DripModelExponentialFactory is BaseModelFactory {
  /// @notice Event that indicates a DripModelExponential has been deployed.
  event DeployedDripModelExponential(address indexed dripModel, uint256 ratePerSecond);

  /// @notice Deploys a DripModelExponential contract and emits a DeployedDripModelExponential event that
  /// indicates what the params from the deployment are. This address is then cached inside the
  /// isDeployed mapping.
  /// @return model_ which has an address that is deterministic with the input ratePerSecond_.
  function deployModel(uint256 ratePerSecond_) external returns (DripModelExponential model_) {
    model_ = new DripModelExponential{salt: DEFAULT_SALT}(ratePerSecond_);
    isDeployed[address(model_)] = true;

    emit DeployedDripModelExponential(address(model_), ratePerSecond_);
  }

  /// @return The address where the model is deployed, or address(0) if it isn't deployed.
  function getModel(uint256 ratePerSecond_) external view returns (address) {
    bytes memory dripModelConstructorArgs_ = abi.encode(ratePerSecond_);

    address addr_ = Create2.computeCreate2Address(
      type(DripModelExponential).creationCode, dripModelConstructorArgs_, address(this), DEFAULT_SALT
    );

    return isDeployed[addr_] ? addr_ : address(0);
  }
}
