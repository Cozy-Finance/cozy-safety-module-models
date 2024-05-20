// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.22;

library Create2 {
  /// @notice Computes the address that would result from a CREATE2 call for a contract according
  /// to the spec in https://eips.ethereum.org/EIPS/eip-1014
  /// @return The CREATE2 address as computed using the params.
  /// @param creationCode_ The creation code bytes of the specified contract.
  /// @param constructorArgs_ The abi encoded constructor args.
  /// @param deployer_ The address of the deployer of the contract.
  /// @param salt_ The salt used to compute the create2 address.
  function computeCreate2Address(
    bytes memory creationCode_,
    bytes memory constructorArgs_,
    address deployer_,
    bytes32 salt_
  ) internal pure returns (address) {
    bytes32 bytecodeHash_ = keccak256(bytes.concat(creationCode_, constructorArgs_));
    bytes32 data_ = keccak256(bytes.concat(bytes1(0xff), bytes20(deployer_), salt_, bytecodeHash_));
    return address(uint160(uint256(data_)));
  }
}
