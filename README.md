<img align="right" width="400" height="160" top="140" src="./assets/foundry_huff_banner.jpg">


# Foundry x Huff

[![ci](https://github.com/huff-language/huff-rs/actions/workflows/ci.yaml/badge.svg)](https://github.com/huff-language/huff-rs/actions/workflows/ci.yaml) [![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Discord](https://img.shields.io/discord/980519274600882306)

A [foundry](https://github.com/foundry-rs/foundry) library for working with [huff](https://github.com/huff-language/huff-rs) contracts. Take a look at our [project template](https://github.com/huff-language/huff-project-template) to see an example project that uses this library.


## Installing

First, install the [huff compiler](https://github.com/huff-language/huff-rs) by running:
```
curl -L get.huff.sh | bash
```

Then, install this library with [forge](https://github.com/foundry-rs/foundry):
```
forge install huff-language/foundry-huff
```


## Usage

The HuffDeployer is a Solidity library that takes a filename and deploys the corresponding Huff contract, returning the address that the bytecode was deployed to. To use it, simply import it into your file by doing:

```js
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
```

To compile contracts, you can use `HuffDeployer.deploy(string fileName)`, which takes in a single string representing the filename's path relative to the `src` directory. Note that the file ending, i.e. `.huff`, must be omitted.
Here is an example deployment (where the contract is located in [`src/test/contracts/Number.huff`](./src/test/contracts/Number.huff)):

```solidity
// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.0 <0.9.0;

import {HuffDeployer} from "foundry-huff/HuffDeployer";

interface Number {
  function setNumber(uint256) external;
  function getNumber() external returns (uint256);
}

contract HuffDeployerExample {
  function deploy() public {
    // Deploy a new instance of src/test/contracts/Number.huff
    address addr = HuffDeployer.deploy("test/contracts/Number");

    // To call a function on the deployed contract, create an interface and wrap the address like so
    Number number = Number(addr);
  }

  function deployForProduction() public {
    // Deploy to production network with broadcast enabled
    address addr = HuffDeployer
      .config()
      .set_broadcast(true)                // Enable production deployment
      .with_deployer(tx.origin)           // Set deployer to transaction origin
      .deploy("test/contracts/Number");

    Number number = Number(addr);
  }
}
```

To deploy a Huff contract with constructor arguments, you can _chain_ commands onto the HuffDeployer.

**Note**: All the examples below show both test mode (using `vm.prank()` for simulation) and production mode (using `vm.broadcast()` for real deployment). The production mode enables actual on-chain deployment to live networks.

For example, to deploy the contract [`src/test/contracts/Constructor.huff`](src/test/contracts/Constructor.huff) with arguments `(uint256(0x420), uint256(0x420))`, you are encouraged to follow the logic defined in the `deploy` function of the `HuffDeployerArguments` contract below.

```solidity
// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.0 <0.9.0;

import {HuffDeployer} from "foundry-huff/HuffDeployer";

interface Constructor {
  function getArgOne() external returns (address);
  function getArgTwo() external returns (uint256);
}

contract HuffDeployerArguments {
  function deploy() public {
    // Deploy the contract with arguments (test mode)
    address addr = HuffDeployer
      .config()
      .with_args(bytes.concat(abi.encode(uint256(0x420)), abi.encode(uint256(0x420))))
      .deploy("test/contracts/Constructor");

    // To call a function on the deployed contract, create an interface and wrap the address
    Constructor construct = Constructor(addr);

    // Validate we deployed the Constructor with the correct arguments
    assert(construct.getArgOne() == address(0x420));
    assert(construct.getArgTwo() == uint256(0x420));
  }

  function deployProduction() public {
    // Deploy the contract with arguments (production mode)
    address addr = HuffDeployer
      .config()
      .set_broadcast(true)                // Enable production deployment
      .with_deployer(msg.sender)          // Set deployer address
      .with_args(bytes.concat(abi.encode(uint256(0x420)), abi.encode(uint256(0x420))))
      .deploy("test/contracts/Constructor");

    Constructor construct = Constructor(addr);
    
    // Note: In production, you would verify deployment via external calls or events
  }

  function depreciated_deploy() public {
    address addr = HuffDeployer.deploy_with_args(
      "test/contracts/Constructor",
      bytes.concat(abi.encode(uint256(0x420)), abi.encode(uint256(0x420)))
    );

    // ...
  }
}
```

HuffDeployer also enables you to instantiate contracts, from the test file, even if they have _no constructor macro_!

This is possible by using [Foundry](https://github.com/foundry-rs/foundry)'s [ffi](https://book.getfoundry.sh/cheatcodes/ffi.html) cheatcode.

_NOTE: It is highly recommended that you read the foundry book, or at least familiarize yourself with foundry, before using this library to avoid easily susceptible footguns._

Let's use the huff contract [`src/test/contracts/NoConstructor.huff`](./src/test/contracts/NoConstructor.huff), which has no defined constructor macro. The inline-instantiation defined in the `deploy` function of the `HuffDeployerCode` contract below is recommended.

```solidity
// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.0 <0.9.0;

import {HuffDeployer} from "foundry-huff/HuffDeployer";

interface Constructor {
  function getArgOne() external returns (address);
  function getArgTwo() external returns (uint256);
}

contract HuffDeployerCode {

  function deploy() public {
    // Define a new constructor macro as a string
    string memory constructor_macro = "#define macro CONSTRUCTOR() = takes(0) returns (0) {"
      "    // Copy the first argument into memory \n"
      "    0x20                        // [size] - byte size to copy \n"
      "    0x40 codesize sub           // [offset, size] - offset in the code to copy from\n "
      "    0x00                        // [mem, offset, size] - offset in memory to copy to \n"
      "    codecopy                    // [] \n"
      "    // Store the first argument in storage\n"
      "    0x00 mload                  // [arg] \n"
      "    [CONSTRUCTOR_ARG_ONE]       // [CONSTRUCTOR_ARG_ONE, arg] \n"
      "    sstore                      // [] \n"
      "    // Copy the second argument into memory \n"
      "    0x20                        // [size] - byte size to copy \n"
      "    0x20 codesize sub           // [offset, size] - offset in the code to copy from \n"
      "    0x00                        // [mem, offset, size] - offset in memory to copy to \n"
      "    codecopy                    // [] \n"
      "    // Store the second argument in storage \n"
      "    0x00 mload                  // [arg] \n"
      "    [CONSTRUCTOR_ARG_TWO]       // [CONSTRUCTOR_ARG_TWO, arg] \n"
      "    sstore                      // [] \n"
      "}";

    // Deploy the contract with arguments (test mode - default)
    address addr = HuffDeployer
      .config()
      .with_args(bytes.concat(abi.encode(uint256(0x420)), abi.encode(uint256(0x420))))
      .with_code(constructor_macro)
      .deploy("test/contracts/NoConstructor");

    // To call a function on the deployed contract, create an interface and wrap the address
    Constructor construct = Constructor(addr);

    // Validate we deployed the Constructor with the correct arguments
    assert(construct.getArgOne() == address(0x420));
    assert(construct.getArgTwo() == uint256(0x420));
  }

  function deployProduction() public {
    // Same constructor macro as above
    string memory constructor_macro = "..."; // (truncated for brevity)

    // Deploy to production with inline code injection
    address addr = HuffDeployer
      .config()
      .set_broadcast(true)                // Enable production deployment
      .with_deployer(tx.origin)           // Set deployer address
      .with_args(bytes.concat(abi.encode(uint256(0x420)), abi.encode(uint256(0x420))))
      .with_code(constructor_macro)       // Inject constructor code
      .deploy("test/contracts/NoConstructor");

    // Production deployment completed - verify externally
  }

  function depreciated_deploy_with_code() public {
    address addr = HuffDeployer.deploy_with_code(
      "test/contracts/Constructor",
      constructor_macro
    );

    // ...
  }
}
```

## Production Deployment

The foundry-huff library now supports both test environment simulation and real production network deployment through the broadcast functionality. This enables seamless transition from development to production.

### Test vs Production Mode

The HuffDeployer can operate in two modes:

- **Test Mode** (default): Uses `vm.prank()` to simulate deployment contexts for testing
- **Production Mode**: Uses `vm.broadcast()` to execute real transactions on networks

### Basic Production Deployment

To deploy a Huff contract to a real network, use the `set_broadcast(true)` method:

```solidity
// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract ProductionDeploy is Script {
    function run() public {
        // Deploy to production network with broadcast mode
        address deployedContract = HuffDeployer
            .config()
            .set_broadcast(true)              // Enable production deployment
            .with_deployer(tx.origin)         // Set deployer address
            .deploy("test/contracts/RememberCreator");
        
        console.log("Contract deployed at:", deployedContract);
    }
}
```

### Complete Production Example

Here's a complete example deploying a contract that remembers its creator:

#### 1. Deploy the Contract

Use the provided deployment script to deploy to a local network:

```bash
forge script scripts/Deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $SINGER_KEY
```

This command will:
- Compile the Huff contract
- Deploy it to the specified network (localhost:8545)
- Use the private key from `$SINGER_KEY` environment variable
- The contract will be deployed with the creator address set to the address corresponding to `$SINGER_KEY`

#### 2. Verify Deployment

After deployment, you'll receive a contract address (e.g., `0xAF194984fa4570B8fE909c102844Bd2584E6E90b`). Verify the deployment:

```bash
# Call the CREATOR() function to verify the creator address
cast call 0xAF194984fa4570B8fE909c102844Bd2584E6E90b "CREATOR() (address)"
```

This should return the address that corresponds to your `$SINGER_KEY`, confirming that the contract correctly stored the deployer's address.

### Deployment with Constructor Arguments

For contracts requiring constructor arguments in production:

```solidity
contract ProductionDeployWithArgs is Script {
    function run() public {
        address deployedContract = HuffDeployer
            .config()
            .set_broadcast(true)
            .with_deployer(tx.origin)
            .with_args(bytes.concat(
                abi.encode(address(0x1234567890123456789012345678901234567890)),
                abi.encode(uint256(1000))
            ))
            .deploy("test/contracts/Constructor");
    }
}
```

### Advanced Configuration

You can combine multiple configuration options for complex deployment scenarios:

```solidity
contract AdvancedProductionDeploy is Script {
    function run() public {
        // Deploy with custom code injection and arguments
        address deployedContract = HuffDeployer
            .config()
            .set_broadcast(true)                    // Production mode
            .with_deployer(msg.sender)              // Custom deployer
            .with_value(1 ether)                    // Deploy with ETH value
            .with_args(abi.encode(msg.sender))      // Constructor arguments
            .with_code("// Custom constructor code") // Additional code
            .deploy("my/contract");
    }
}
```

### Security and Best Practices

#### Private Key Management
- **Never hardcode private keys** in your scripts or source code
- Use environment variables: `export SINGER_KEY=0x...`
- Consider using hardware wallets for mainnet deployments
- Use dedicated deployment accounts with limited funds

#### Network Configuration
```bash
# Local development
forge script scripts/Deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $SINGER_KEY

# Testnet deployment
forge script scripts/Deploy.s.sol --rpc-url https://goerli.infura.io/v3/YOUR_KEY --broadcast --private-key $SINGER_KEY

# Mainnet deployment (use with extreme caution)
forge script scripts/Deploy.s.sol --rpc-url https://mainnet.infura.io/v3/YOUR_KEY --broadcast --private-key $SINGER_KEY
```

#### Deployment Verification
Always verify your deployments:

1. **Check contract address**: Ensure the contract was deployed to the expected address
2. **Verify state**: Call view functions to confirm proper initialization
3. **Test functionality**: Execute test transactions on testnets before mainnet
4. **Gas estimation**: Use `--estimate-gas` flag to preview transaction costs

#### Production Checklist
- [ ] Contract compiled successfully with `huffc`
- [ ] Deployment script tested on local network
- [ ] Private keys securely managed
- [ ] Network RPC URL configured correctly
- [ ] Gas price and limits appropriate for target network
- [ ] Contract verification planned (e.g., Etherscan)
- [ ] Post-deployment testing strategy defined

### Troubleshooting

**Deployment Fails**: Check network connectivity, gas limits, and account balance
**Wrong Creator Address**: Ensure `with_deployer()` is set correctly and private key matches
**Gas Issues**: Huff contracts are gas-optimized, but verify gas limits for complex constructors
**Broadcast Errors**: Confirm `set_broadcast(true)` is called and private key has permissions
```
