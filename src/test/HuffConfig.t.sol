// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.0 <0.9.0;

import "forge-std/Test.sol";

import {INumber} from "./interfaces/INumber.sol";
import {IConstructor} from "./interfaces/IConstructor.sol";
import {HuffConfig} from "../HuffConfig.sol";

contract HuffConfigTest is Test {
  HuffConfig public config;
  INumber public number;

  function setUp() public {
    config = new HuffConfig();
  }

  function testWithArgs(bytes memory some) public {
    config.with_args(some);
    assertEq(config.args(), some);
  }

  function testWithCode(string memory code) public {
    config.with_code(code);
    assertEq(config.code(), code);
  }

}