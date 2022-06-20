// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../../lib/ds-test/test.sol";
import "forge-std/console.sol";
import "../HuffDeployer.sol";

import "./interfaces/ISimpleStore.sol";

contract SimpleStoreTest is DSTest {
    ///@notice create a new instance of HuffDeployer
    HuffDeployer huffDeployer = new HuffDeployer();

    ISimpleStore simpleStore;

    function setUp() public {
        ///@notice deploy a new instance of ISimplestore by passing in the address of the deployed Huff contract
        simpleStore = ISimpleStore(huffDeployer.deployContract("SimpleStore"));
    }

    function testGet() public {
        simpleStore.get();
    }

    function testStore(uint256 val) public {
        simpleStore.store(val);
    }
}
