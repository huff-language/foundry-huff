// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {strings} from "stringutils";
import {HuffDeployer} from "./HuffDeployer.sol";

contract StatefulDeployer {
  using strings for *;

  /// @notice additional code to append to the source file
  string public code;

  /// @notice arguments to append to the bytecode
  bytes public args;

  /// @notice sets the code to be appended to the source file
  function setCode(string memory acode) public {
    code = acode;
  }

  /// @notice sets the arguments to be appended to the bytecode
  function setArgs(bytes memory aargs) public {
    args = aargs;
  }

  /// @notice Deployment wrapper
  function deploy(string memory file) public returns (address) {
    // Split the file into it's parts
    strings.slice memory s = file.toSlice();
    strings.slice memory delim = "/".toSlice();
    string[] memory parts = new string[](s.count(delim));
    for (uint i = 0; i < parts.length; i++) {
      parts[i] = s.split(delim).toString();
    }

    // Re-concatenate the file with a "__TEMP__" prefix
    string memory tempFile = parts[i];
    for (uint i = 1; i < parts.length - 1; i++) {
      tempFile = string.concat(tempFile, "/", parts[i]);
    }
    tempFile = string.concat(tempFile, "/", "__TEMP__", parts[parts.length - 1]);

    // Paste the code in a new temp file
    string[] memory create_cmds = new string[](6);
    create_cmds[0] = "echo";
    create_cmds[1] = code;
    create_cmds[2] = "|";
    create_cmds[3] = "cat";
    create_cmds[4] = ">";
    create_cmds[5] = tempFile;
    HuffDeployer.vm.ffi(create_cmds);

    // echo "" | cat > src/__TEMP__test/contracts/Number.huff

    // Append the real code to the temp file
    string[] memory append_cmds = new string[](4);
    append_cmds[0] = "cat";
    append_cmds[1] = file;
    append_cmds[2] = ">>";
    append_cmds[3] = tempFile;
    HuffDeployer.vm.ffi(append_cmds);

    // Deploy with args the temp file
    return HuffDeployer.deploy_with_args(tempFile, args);
  }


}