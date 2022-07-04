// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Vm} from "forge-std/Vm.sol";

contract HuffConfig {

  /// @notice Initializes cheat codes in order to use ffi to compile Huff contracts
  Vm public constant vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

  /// @notice additional code to append to the source file
  string public code;

  /// @notice arguments to append to the bytecode
  bytes public args;

  /// @notice sets the code to be appended to the source file
  function with_code(string memory acode) public returns (HuffConfig) {
    code = acode;
    return this;
  }

  /// @notice sets the arguments to be appended to the bytecode
  function with_args(bytes memory aargs) public returns (HuffConfig) {
    args = aargs;
    return this;
  }

  /// @notice Deploy the Contract
  function deploy(string memory file) public returns (address) {

    // TODO: add code to temp file and compile that temp file

    /// Create a list of strings with the commands necessary to compile Huff contracts
    string[] memory cmds = new string[](3);
    cmds[0] = "huffc";
    cmds[1] = string(string.concat("src/", file, ".huff"));
    cmds[2] = "-b";

    /// @notice compile the Huff contract and return the bytecode
    bytes memory bytecode = vm.ffi(cmds);
    bytes memory concatenated = bytes.concat(bytecode, args);

    /// @notice deploy the bytecode with the create instruction
    address deployedAddress;
    assembly {
      deployedAddress := create(0, add(concatenated, 0x20), mload(concatenated))
    }

    /// @notice check that the deployment was successful
    require(
      deployedAddress != address(0),
      "HuffDeployer could not deploy contract"
    );

    /// @notice return the address that the contract was deployed to
    return deployedAddress;
  }
}