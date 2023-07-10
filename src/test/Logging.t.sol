// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.0 <0.9.0;

import "forge-std/Test.sol";

import {HuffConfig} from "../HuffConfig.sol";
import {HuffDeployer} from "../HuffDeployer.sol";
import {INumber} from "./interfaces/INumber.sol";
import {IConstructor} from "./interfaces/IConstructor.sol";

contract LoggingTest is Test {
    event LogOne();
    event LogTwo(address indexed a);
    event LogThree(address indexed a, uint256 indexed b);
    event LogFour(address indexed a, uint256 indexed b, bytes32 indexed c);
    event Extended(
        address indexed a, uint256 indexed b, bytes32 indexed h1, bytes32 h2, bytes32 two
    );

    function testLoggingWithArgs() public {
       vm.recordLogs();
        HuffDeployer.deploy_with_args(
            "test/contracts/LotsOfLogging",
            bytes.concat(abi.encode(address(0x420)), abi.encode(uint256(0x420)))
        );
        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 5);
        assertEq(entries[0].topics.length, 1);
        assertEq(entries[0].topics[0], bytes32(uint256(keccak256("LogOne()"))));
        assertEq(entries[1].topics.length, 2);
        assertEq(entries[1].topics[0], bytes32(uint256(keccak256("LogTwo(address)"))));
        // assertEq(entries[1].topics[1], ?); should be address from deployed config
        assertEq(entries[2].topics.length, 3);
        assertEq(entries[2].topics[0], bytes32(uint256(keccak256("LogThree(address,uint256)"))));
        // assertEq(entries[2].topics[1], ?); should be address from deployed config
        assertEq(entries[2].topics[2], bytes32(uint256(0x0)));
        assertEq(entries[3].topics.length, 4);
        assertEq(entries[3].topics[0], bytes32(uint256(keccak256("LogFour(address,uint256,bytes32)"))));
        // assertEq(entries[3].topics[1], ?); should be address from deployed config
        assertEq(entries[3].topics[2], bytes32(uint256(0x0)));
        assertEq(entries[3].topics[3], bytes32(uint256(keccak256(abi.encode(1)))));
        assertEq(entries[4].topics.length, 4);
        assertEq(entries[4].topics[0], bytes32(uint256(keccak256("Extended(address,uint256,bytes32,bytes32,bytes32)"))));
        // assertEq(entries[4].topics[1], ?); should be address from deployed config
        assertEq(entries[4].topics[2], bytes32(uint256(0x0)));
        assertEq(entries[4].topics[3], bytes32(uint256(keccak256(abi.encode(1)))));
        assertEq(entries[4].data, abi.encode(keccak256(abi.encode(2)), keccak256(abi.encode(3))));
    }

    function testLoggingWithDeploy() public {
        vm.expectEmit(false, true, true, true);
        emit LogOne();
        emit LogTwo(address(0));
        emit LogThree(address(0), 0);
        emit LogFour(address(0), 0, keccak256(abi.encode(1)));
        emit Extended(
            address(0),
            0,
            keccak256(abi.encode(1)),
            keccak256(abi.encode(2)),
            keccak256(abi.encode(3))
            );
        HuffDeployer.deploy("test/contracts/LotsOfLogging");
    }

    function testConfigLogging() public {
        HuffConfig config = HuffDeployer.config().with_args(abi.encode(address(0x420)));
        vm.expectEmit(true, true, true, true);
        emit LogOne();
        emit LogTwo(address(config));
        emit LogThree(address(config), 0);
        emit LogFour(address(config), 0, keccak256(abi.encode(1)));
        emit Extended(
            address(config),
            0,
            keccak256(abi.encode(1)),
            keccak256(abi.encode(2)),
            keccak256(abi.encode(3))
            );
        config.deploy("test/contracts/LotsOfLogging");
    }
}
