// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Vm} from "forge-std/Vm.sol";
import {strings} from "stringutils/strings.sol";

contract HuffConfig {
  using strings for *;

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

  /// @notice Checks for huffc binary conflicts
  function binary_check() public {
    string[] memory bincheck = new string[](1);
    bincheck[0] = "./lib/foundry-huff/scripts/binary_check.sh";
    bytes memory retData = vm.ffi(bincheck);
    bytes8 first_bytes = retData[0];
    bool decoded = first_bytes == bytes8(hex"01");
    require(decoded, "Invalid huffc binary. Run `curl -L get.huff.sh | bash` and `huffup` to fix.");
  }

  function bytesToString(bytes32 x) internal pure returns (string memory) {
    string memory result;
    for (uint j = 0; j < x.length; j++) {
      result = string.concat(result, string(abi.encodePacked(uint8(x[j]) % 26 + 97)));
    }
    return result;
  }

  /// @notice Deploy the Contract
  function deploy(string memory file) public returns (address) {
    binary_check();

    // Split the file into it's parts
    strings.slice memory s = file.toSlice();
    strings.slice memory delim = "/".toSlice();
    string[] memory parts = new string[](s.count(delim) + 1);
    for (uint i = 0; i < parts.length; i++) {
      parts[i] = s.split(delim).toString();
    }

    // Get the system time with our script
    string[] memory time = new string[](1);
    time[0] = "./lib/foundry-huff/scripts/rand_bytes.sh";
    bytes memory retData = vm.ffi(time);
    string memory rand_bytes = bytesToString(keccak256(abi.encode(bytes32(retData))));

    // Re-concatenate the file with a "__TEMP__" prefix
    string memory tempFile = parts[0];
    if (parts.length <= 1) {
      tempFile = string.concat("__TEMP__", rand_bytes, tempFile);
    } else {
      for (uint i = 1; i < parts.length - 1; i++) {
        tempFile = string.concat(tempFile, "/", parts[i]);
      }
      tempFile = string.concat(tempFile, "/", "__TEMP__", rand_bytes, parts[parts.length - 1]);
    }

    // Paste the code in a new temp file
    string[] memory create_cmds = new string[](3);
    // TODO: create_cmds[0] = "$(find . -name \"file_writer.sh\")";
    create_cmds[0] = "./lib/foundry-huff/scripts/file_writer.sh";
    create_cmds[1] = string.concat("src/", tempFile, ".huff");
    create_cmds[2] = string.concat(code, "\n");
    vm.ffi(create_cmds);

    // Append the real code to the temp file
    string[] memory append_cmds = new string[](3);
    append_cmds[0] = "./lib/foundry-huff/scripts/read_and_append.sh";
    append_cmds[1] = string.concat("src/", tempFile, ".huff");
    append_cmds[2] = string.concat("src/", file, ".huff");
    vm.ffi(append_cmds);

    /// Create a list of strings with the commands necessary to compile Huff contracts
    string[] memory cmds = new string[](3);
    cmds[0] = "huffc";
    cmds[1] = string(string.concat("src/", tempFile, ".huff"));
    cmds[2] = "-b";

    /// @notice compile the Huff contract and return the bytecode
    bytes memory bytecode = vm.ffi(cmds);
    bytes memory concatenated = bytes.concat(bytecode, args);

    // Clean up temp files
    string[] memory cleanup = new string[](2);
    cleanup[0] = "rm";
    cleanup[1] = string.concat("src/", tempFile, ".huff");
    vm.ffi(cleanup);

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