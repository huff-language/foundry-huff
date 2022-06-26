// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13 <0.9.0; 



library HuffDeployer {
    /// @notice Initializes cheat codes in order to use ffi to compile Huff contracts
    VM constant vm = VM(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    ///@notice Compiles a Huff contract and returns the address that the contract was deployeod to
    ///@notice If deployment fails, an error will be thrown
    ///@param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    ///@return deployedAddress - The address that the contract was deployed to

    function deploy(string memory fileName) internal returns (address) {
        ///@notice create a list of strings with the commands necessary to compile Huff contracts
        string[] memory cmds = new string[](5);
        cmds[0] = "npx";
        cmds[1] = "huffc";
        cmds[2] = string(string.concat("src/", fileName, ".huff"));
        cmds[3] = "-n";
        cmds[4] = "--bytecode";

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

///@notice This cheat codes interface is named _CheatCodes so you can use the CheatCodes interface in other testing files without errors
interface VM {
    function ffi(string[] calldata) external returns (bytes memory);
}