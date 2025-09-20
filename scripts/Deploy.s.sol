// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {HuffDeployer} from "src/HuffDeployer.sol";

contract Deploy is Script {
    function run() public {
        console.log("Deploying contract with deployer:", tx.origin);
        HuffDeployer.config().set_broadcast(true).with_deployer(tx.origin).deploy(
            "test/contracts/RememberCreator"
        );
    }
}
