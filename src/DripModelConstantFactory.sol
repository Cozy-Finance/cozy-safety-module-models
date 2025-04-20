// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

import {IDripModel} from "cozy-safety-module-libs/interfaces/IDripModel.sol";
import {DripModelConstant} from "./DripModelConstant.sol";
import {BaseModelFactory} from "./abstract/BaseModelFactory.sol";
import {Create2} from "./lib/Create2.sol";

/**
 * @notice The factory for deploying a DripModelConstant contract.
 */
contract DripModelConstantFactory {
  /// @notice Event that indicates a DripModelConstant has been deployed.
  event DeployedDripModelConstant(address indexed dripModel, address indexed owner, uint256 amountPerSecond);

  /// @notice Deploys a DripModelConstant contract and emits a DeployedDripModelConstant event that
  /// indicates what the params from the deployment are. This address is then cached inside the
  /// isDeployed mapping.
  /// @return model_ which has an address that is deterministic with the input amountPerSecond_.
  function deployModel(address owner_, uint256 amountPerSecond_, bytes32 baseSalt_)
    external
    returns (IDripModel model_)
  {
    model_ = new DripModelConstant{salt: _computeDeploySalt(msg.sender, baseSalt_)}(owner_, amountPerSecond_);
    emit DeployedDripModelConstant(address(model_), owner_, amountPerSecond_);
  }

  /// @notice Given a `caller_`, `owner_`, `amountPerSecond_`, and `baseSalt_`, return the address of the
  /// DripModelConstant deployed from the `DripModelConstantFactory`.
  function computeAddress(address caller_, address owner_, uint256 amountPerSecond_, bytes32 baseSalt_)
    external
    view
    returns (address)
  {
    bytes memory dripModelConstructorArgs_ = abi.encode(owner_, amountPerSecond_);
    return Create2.computeCreate2Address(
      type(DripModelConstant).creationCode,
      dripModelConstructorArgs_,
      address(this),
      _computeDeploySalt(caller_, baseSalt_)
    );
  }

  /// @notice Given a `caller_` and `salt_`, return the salt used to compute the DripModelConstant address deployed from
  /// the `DripModelConstantFactory`.
  /// @param caller_ The caller of the `deployModel` function.
  /// @param salt_ Used to compute the resulting address of the `DripModelConstant` along with `caller_`.
  function _computeDeploySalt(address caller_, bytes32 salt_) internal view returns (bytes32) {
    // To avoid front-running of `DripModelConstant` deploys, msg.sender is used for the deploy salt.
    return keccak256(abi.encodePacked(salt_, caller_, block.chainid));
  }
}
