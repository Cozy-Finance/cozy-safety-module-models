// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;

import {DripModelConstantFactory} from "../src/DripModelConstantFactory.sol";
import {DripModelExponentialFactory} from "../src/DripModelExponentialFactory.sol";
import "forge-std/Script.sol";

/**
 * @notice Purpose: Local deploy, testing, and production.
 *
 * This script deploys the Model Factory contracts.
 * Before executing, the configuration section in the script should be updated.
 *
 * To run this script:
 *
 * ```sh
 * # Start anvil, forking from the current state of the desired chain.
 * anvil --fork-url $OPTIMISM_RPC_URL
 *
 * # In a separate terminal, perform a dry run of the script.
 * forge script script/DeployModelFactories.s.sol \
 *   --rpc-url "http://127.0.0.1:8545" \
 *   -vvvv
 *
 * # Or, to broadcast a transaction.
 * forge script script/DeployModelFactories.s.sol \
 *   --rpc-url "http://127.0.0.1:8545" \
 *   --private-key $OWNER_PRIVATE_KEY \
 *   --broadcast \
 *   -vvvv
 * ```
 */
contract DeployModelFactories is Script {
  /// @notice Deploys all the Model Factory contracts
  function run() public {
    console2.log("Deploying Cozy Safety Module Model Factories...");

    console2.log("  Deploying DripModelExponentialFactory...");
    vm.broadcast();
    address dripModelExponentialFactory = address(new DripModelExponentialFactory());
    console2.log("  DripModelExponentialFactory deployed,", dripModelExponentialFactory);

    console2.log("  Deploying DripModelConstantFactory...");
    vm.broadcast();
    address dripModelConstantFactory = address(new DripModelConstantFactory());
    console2.log("  DripModelConstantFactory deployed,", dripModelConstantFactory);

    console2.log("Finished deploying Cozy Safety Module Model Factories");
  }
}
