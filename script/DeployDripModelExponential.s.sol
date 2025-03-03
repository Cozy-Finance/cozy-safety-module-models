// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

import {DripModelExponentialFactory} from "../src/DripModelExponentialFactory.sol";
import {ExponentialDripLib} from "../src/lib/ExponentialDripLib.sol";
import "script/ScriptUtils.sol";

/**
 * @notice Purpose: Local deploy, testing, and production.
 *
 * This script deploys a DripModelExponential contract.
 * Before executing, the input json file `script/input/<chain-id>/deploy-drip-model-exponential-<test or
 * production>.json`
 * should be reviewed.
 *
 * Config Params:
 *
 * factory: The address of the factory which will deploy the DripModelExponential contract.
 *
 * dripRate: dripRate percentage expressed as an 18 decimal precision uint256. For example,
 * 25% dripRate should be 0.25e18, or `250000000000000000` in a JSON file.
 *
 * dripPeriodInSeconds: The number of seconds in which the drip takes place over.
 * For example, one year would be 31557600.
 *
 * To run this script:
 *
 * ```sh
 * # Start anvil, forking from the current state of the desired chain.
 * anvil --fork-url $OPTIMISM_RPC_URL
 *
 * # In a separate terminal, perform a dry run of the script.
 * forge script script/DeployDripModelExponential.s.sol \
 *   --sig "run(string)" "deploy-drip-model-exponential-<test or production>"
 *   --rpc-url "http://127.0.0.1:8545" \
 *   -vvvv
 *
 * # Or, to broadcast a transaction.
 * forge script script/DeployDripModelExponential.s.sol \
 *   --sig "run(string)" "deploy-drip-model-exponential-<test or production>"
 *   --rpc-url "http://127.0.0.1:8545" \
 *   --private-key $OWNER_PRIVATE_KEY \
 *   --broadcast \
 *   -vvvv
 * ```
 */
contract DeployDripModelExponential is ScriptUtils {
  using stdJson for string;

  // ---------------------------
  // -------- Execution --------
  // ---------------------------

  function run(string memory fileName_) public {
    string memory json_ = readInput(fileName_);

    DripModelExponentialFactory factory_ = DripModelExponentialFactory(json_.readAddress(".factory"));
    uint256 dripRate_ = json_.readUint(".dripRate");
    uint256 dripPeriodInSeconds_ = json_.readUint(".dripPeriodInSeconds");
    uint256 finalRate_ = 1e18 - dripRate_;
    uint256 dripRatePerSecond_ = ExponentialDripLib.calculateDripRate(finalRate_, 1e18, dripPeriodInSeconds_);

    console2.log("Deploying DripModelExponential...");
    console2.log("    factory", address(factory_));
    console2.log("    dripRate percentage", dripRate_ * 100 / 1e18);
    console2.log("    dripRatePerSecond", dripRatePerSecond_);

    address availableModel_ = factory_.getModel(dripRatePerSecond_);

    if (availableModel_ == address(0)) {
      vm.broadcast();
      availableModel_ = address(factory_.deployModel(dripRatePerSecond_));
      console2.log("New DripModelExponential deployed");
    } else {
      // A DripModelExponential exactly like the one you wanted already exists!
      // Since models can be re-used, there's no need to deploy a new one.
      console2.log("Found existing DripModelExponential with specified configs.");
    }

    console2.log("Your DripModelExponential is available at this address:", availableModel_);

    vm.broadcast();
    address defaultModel_ = address(factory_.deployModel(1e18));
    console2.log("Your 100% drip model is available at this address:", defaultModel_);
  }
}
