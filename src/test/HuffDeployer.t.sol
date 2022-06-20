// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../../lib/ds-test/test.sol";
import "forge-std/console.sol";
import "../HuffDeployer.sol";

interface Number {
    function setNumber(uint256) external;
    function getNumber() external returns (uint256);
}

contract HuffDeployerTest is DSTest {
    ///@notice create a new instance of HuffDeployer
    HuffDeployer huffDeployer = new HuffDeployer();

    Number number;

    function setUp() public {
        ///@notice deploy a new instance of ISimplestore by passing in the address of the deployed Huff contract
        number = Number(huffDeployer.deploy("test/contracts/Number"));
    }

    function testSet(uint256 num) public {
        number.setNumber(num);
        assertEq(num, number.getNumber());
    }
}