// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

///@notice This cheat codes interface is named _CheatCodes so you can use the CheatCodes interface in other testing files without errors
interface _CheatCodes {
    function ffi(string[] calldata) external returns (bytes memory);
}

contract HuffDeployer {
    address constant HEVM_ADDRESS =
        address(bytes20(uint160(uint256(keccak256("hevm cheat code")))));

    /// @notice Initializes cheat codes in order to use ffi to compile Huff contracts
    _CheatCodes cheatCodes = _CheatCodes(HEVM_ADDRESS);

    ///@notice Compiles a Huff contract and returns the address that the contract was deployeod to
    ///@notice If deployment fails, an error will be thrown
    ///@param fileName - The file name of the Huff contract. For example, the file name for "SimpleStore.huff" is "SimpleStore"
    ///@return deployedAddress - The address that the contract was deployed to

    function deploy(string memory fileName) public returns (address) {
        ///@notice create a list of strings with the commands necessary to compile Huff contracts
        string[] memory cmds = new string[](4);
        cmds[0] = "huffc";
        cmds[1] = string(string.concat("src/", fileName, ".huff"));
        cmds[2] = "--bytecode";
        cmds[3] = "-n";

        ///@notice compile the Huff contract and return the bytecode
        bytes memory bytecode = cheatCodes.ffi(cmds);

        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(
            deployedAddress != address(0),
            "HuffDeployer could not deploy contract"
        );

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }
}
