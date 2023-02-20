// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Vm} from "forge-std/Vm.sol";
import {HuffConfig} from "./HuffConfig.sol";

library HuffDeployer {
    /// @notice Create a new huff config
    function config() public returns (HuffConfig) {
        return new HuffConfig();
    }

    // @notice Deterministically create a new huff config using create2 and a salt
    function config_with_create_2(uint256 salt) public returns (HuffConfig) {
        return new HuffConfig{salt: bytes32(salt)}();
    }

    // @notice Get the address of a HuffConfig deployed with config_with_create_2
    function get_config_with_create_2(uint256 salt) public view returns (address) {
        return 
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff), address(this), bytes32(salt), keccak256(type(HuffConfig).creationCode)
                            )
                        )
                    )
                )
            );
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @return The address that the contract was deployed to
    function deploy(string memory fileName) internal returns (address) {
        return config().deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @return The address that the contract was deployed to
    function broadcast(string memory fileName) internal returns (address) {
        return config().set_broadcast(true).deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @param value - Value to deploy with
    /// @return The address that the contract was deployed to
    function deploy_with_value(string memory fileName, uint256 value) internal returns (address) {
        return config().with_value(value).deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @param value - Value to deploy with
    /// @return The address that the contract was deployed to
    function broadcast_with_value(string memory fileName, uint256 value)
        internal
        returns (address)
    {
        return config().set_broadcast(true).with_value(value).deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @param args - Constructor Args to append to the bytecode
    /// @return The address that the contract was deployed to
    function deploy_with_args(string memory fileName, bytes memory args)
        internal
        returns (address)
    {
        return config().with_args(args).deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @param args - Constructor Args to append to the bytecode
    /// @return The address that the contract was deployed to
    function broadcast_with_args(string memory fileName, bytes memory args)
        internal
        returns (address)
    {
        return config().set_broadcast(true).with_args(args).deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @param code - Code to append to the file source code (e.g. a constructor macro to make the contract instantiable)
    /// @return The address that the contract was deployed to
    function deploy_with_code(string memory fileName, string memory code)
        internal
        returns (address)
    {
        return config().with_code(code).deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @param code - Code to append to the file source code (e.g. a constructor macro to make the contract instantiable)
    /// @return The address that the contract was deployed to
    function broadcast_with_code(string memory fileName, string memory code)
        internal
        returns (address)
    {
        return config().set_broadcast(true).with_code(code).deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @param code - Code to append to the file source code (e.g. a constructor macro to make the contract instantiable)
    /// @param args - Constructor Args to append to the bytecode
    /// @return The address that the contract was deployed to
    function deploy_with_code_args(string memory fileName, string memory code, bytes memory args)
        internal
        returns (address)
    {
        return config().with_code(code).with_args(args).deploy(fileName);
    }

    /// @notice Compiles a Huff contract and returns the address that the contract was deployeod to
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @param code - Code to append to the file source code (e.g. a constructor macro to make the contract instantiable)
    /// @param args - Constructor Args to append to the bytecode
    /// @return The address that the contract was deployed to
    function broadcast_with_code_args(string memory fileName, string memory code, bytes memory args)
        internal
        returns (address)
    {
        return config().set_broadcast(true).with_code(code).with_args(args).deploy(fileName);
    }
}
