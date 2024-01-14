// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "../HuffConfig.sol";
import {HuffDeployer} from "../HuffDeployer.sol";

interface Examples {
    function logTest(
        uint256 start,
        uint256 size,
        uint256 mem_ptr
    ) external pure;
}

contract ConsoleTests is Test {
    Examples public examples;

    function setUp() public {
        examples = Examples(
            HuffDeployer.config().deploy("test/contracts/HuffConsoleWrapper")
        );
    }

    function testLog() public {
        // 71752852194630 = 0x414243444546
        vm.roll(9);

        examples.logTest(71752852194630, 32, 256);
    }
}
