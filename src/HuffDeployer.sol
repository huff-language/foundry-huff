// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Vm} from "forge-std/Vm.sol";
import {HuffConfig} from "./HuffConfig.sol";

library HuffDeployer {
    /// @notice Create a new huff config
    function config() public returns (HuffConfig) {
        return new HuffConfig();
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @notice If deployment fails, an error will be thrown
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @return deployedAddress - The address that the contract was deployed to
    function deploy(string memory fileName) internal returns (address) {
        return new HuffConfig().deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @notice If deployment fails, an error will be thrown
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @param args - Constructor Args to append to the bytecode
    /// @return deployedAddress - The address that the contract was deployed to
    function deploy_with_args(string memory fileName, bytes memory args) internal returns (address) {
        return new HuffConfig().with_args(args).deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @notice If deployment fails, an error will be thrown
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @param code - Code to append to the file source code (e.g. a constructor macro to make the contract instantiable)
    /// @return deployedAddress - The address that the contract was deployed to
    function deploy_with_code(string memory fileName, string memory code) internal returns (address) {
        return new HuffConfig().with_code(code).deploy(fileName);
    }
}