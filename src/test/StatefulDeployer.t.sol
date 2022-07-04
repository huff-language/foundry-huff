// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.0 <0.9.0;

import "forge-std/Test.sol";

import {INumber} from "./interfaces/INumber.sol";
import {IConstructor} from "./interfaces/IConstructor.sol";
import {StatefulDeployer} from "../StatefulDeployer.sol";

contract StatefulDeployerTest is Test {
  StatefulDeployer public deployer;
  INumber public number;

  function setUp() public {
    deployer = new StatefulDeployer();
  }

  function testSetArgs(bytes memory some) public {
    deployer.setArgs(some);
    assertEq(deployer.args(), some);
  }

  function testSetCode(string memory code) public {
    deployer.setCode(code);
    assertEq(deployer.code(), code);
  }

  function testDeployWithArgsAndCode() public {
    // Create Constructor using Chaining
    // chained = Constructor(HuffDeployer.with_args(bytes.concat(first_arg, abi.encode(uint256(0x420)))).deploy("test/contracts/Constructor"));

    // // Create Constructor with code and args
    // no_constructor = Constructor(
    //     HuffDeployer
    //     .with_args(bytes.concat(first_arg, abi.encode(uint256(0x420))))
    //     .with_code("",
    //         "#define macro CONSTRUCTOR() = takes(0) returns (0) {",
    //         "    // Copy the first argument into memory",
    //         "    0x20                        // [size] - byte size to copy",
    //         "    0x40 codesize sub           // [offset, size] - offset in the code to copy from",
    //         "    0x00                        // [mem, offset, size] - offset in memory to copy to",
    //         "    codecopy                    // []",
    //         "    // Store the first argument in storage",
    //         "    0x00 mload                  // [arg]",
    //         "    [CONSTRUCTOR_ARG_ONE]       // [CONSTRUCTOR_ARG_ONE, arg]",
    //         "    sstore                      // []",
    //         "    // Copy the second argument into memory",
    //         "    0x20                        // [size] - byte size to copy",
    //         "    0x20 codesize sub           // [offset, size] - offset in the code to copy from",
    //         "    0x00                        // [mem, offset, size] - offset in memory to copy to",
    //         "    codecopy                    // []",
    //         "    // Store the second argument in storage",
    //         "    0x00 mload                  // [arg]",
    //         "    [CONSTRUCTOR_ARG_TWO]       // [CONSTRUCTOR_ARG_TWO, arg]",
    //         "    sstore                      // []",
    //         "}"
    //     )
    //     .deploy()
    // );

    number = INumber(deployer.deploy("test/contracts/Number"));
    assertEq(number.getNumber(), 0);
    number.setNumber(42);
    assertEq(number.getNumber(), 42);
  }
}