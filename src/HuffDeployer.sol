// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13 <0.9.0;

import "forge-std/Test.sol";

contract HuffDeployer is Test {
    /// @notice Compiles a Huff contract and returns the address that the contract was deployed to
    /// @notice If deployment fails, an error will be thrown
    /// @param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    /// @return deployedAddress - The address that the contract was deployed to
    function deploy(string memory fileName) public returns (address) {
        /// @notice create a list of strings with the commands necessary to compile Huff contracts
        string[] memory cmds = new string[](3);
        cmds[0] = "huffc";
        cmds[1] = string(string.concat("src/", fileName, ".huff"));
        cmds[2] = "-b";

        /// @notice compile the Huff contract and return the bytecode
        bytes memory bytecode = vm.ffi(cmds);

        /// @notice deploy the bytecode with the create instruction
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
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
