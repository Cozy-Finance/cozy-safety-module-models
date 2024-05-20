// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

import {DripModelConstantFactory} from "../src/DripModelConstantFactory.sol";
import "script/ScriptUtils.sol";

/**
 * @notice Purpose: Local deploy, testing, and production.
 *
 * This script deploys a DripModelConstant contract.
 * Before executing, the input json file `script/input/<chain-id>/deploy-drip-model-constant-<test or
 * production>.json`
 * should be reviewed.
 *
 * Config Params:
 *
 * factory: The address of the factory which will deploy the DripModelConstant contract.
 *
 * owner: The owner of the DripModelConstant contract.
 * amountPerSecond: amountPerSecond denoted in the same precision underlying asset to be dripped.
 * baseSalt: The base salt to be used for the DripModelConstant contract deployment.
 *
 * To run this script:
 *
 * ```sh
 * # Start anvil, forking from the current state of the desired chain.
 * anvil --fork-url $OPTIMISM_RPC_URL
 *
 * # In a separate terminal, perform a dry run of the script.
 * forge script script/DeployDripModelConstant.s.sol \
 *   --sig "run(string)" "deploy-drip-model-constant-<test or production>"
 *   --rpc-url "http://127.0.0.1:8545" \
 *   -vvvv
 *
 * # Or, to broadcast a transaction.
 * forge script script/DeployDripModelConstant.s.sol \
 *   --sig "run(string)" "deploy-drip-model-constant-<test or production>"
 *   --rpc-url "http://127.0.0.1:8545" \
 *   --private-key $OWNER_PRIVATE_KEY \
 *   --broadcast \
 *   -vvvv
 * ```
 */
contract DeployDripModelConstant is ScriptUtils {
  using stdJson for string;

  // ---------------------------
  // -------- Execution --------
  // ---------------------------

  function run(string memory fileName_) public {
    string memory json_ = readInput(fileName_);

    DripModelConstantFactory factory_ = DripModelConstantFactory(json_.readAddress(".factory"));
    address owner_ = json_.readAddress(".owner");
    uint256 amountPerSecond_ = json_.readUint(".amountPerSecond");
    bytes32 baseSalt_ = json_.readBytes32(".baseSalt");

    console2.log("Deploying DripModelConstant...");
    console2.log("    factory", address(factory_));
    console2.log("    owner", owner_);
    console2.log("    amountPerSecond", amountPerSecond_);
    console2.log("    baseSalt");
    console2.logBytes32(baseSalt_);

    vm.broadcast();
    address model_ = address(factory_.deployModel(owner_, amountPerSecond_, baseSalt_));
    console2.log("New DripModelConstant deployed: ", model_);
  }
}
