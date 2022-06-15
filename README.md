# Foundry x Huff

NOTE: This will not work until the [huffc yarn package](https://yarnpkg.com/package/huffc) is updated to include the [-n flag for compilation](https://github.com/huff-language/huffc/commit/2e5287afbfdf9cc977b204a4fd1e89c27375b040). Alternatively, you can build from source until then. This note will be removed when the yarn package is updated.

A Foundry template to compile and test Huff contracts. 

```
                                            ,...,
                                          ,::::::<
                                         ,::/^\"``.
                                        ,::/, `   e`.
                                       ,::; |        '.
                                       ,::|  \___,-.  c)
                                       ;::|     \   '-'
                                       ;::|      \
                                       ;::|   _.=`\
                                       `;:|.=` _.=`\
                                         '|_.=`   __\
                                         `\_..==`` /
                                          .'.___.-'.
                                         /          \
                                        ('--......--')
                                        /'--......--'\
                                        `"--......--"`

                                ██   ██ ██    ██ ███████ ███████ 
                                ██   ██ ██    ██ ██      ██      
                                ███████ ██    ██ █████   █████   
                                ██   ██ ██    ██ ██      ██      
                                ██   ██  ██████  ██      ██      

                        
```

<br>


# Installation / Setup

To set up Foundry x Huff, first install the [Huff compiler](https://github.com/huff-language/huffc) with `yarn global add huffc`.

Then set up a new Foundry project with the following command (replacing `huff_project_name` with your new project's name).

```
forge init --template https://github.com/0xKitsune/Foundry-Huff huff_project_name
```

Now you are all set up and ready to go! Below is a quick example of how to set up, deploy and test Huff contracts.


<br>
<br>


# Compiling/Testing Huff Contracts

The HuffDeployer is a pre-built contract that takes a filename and deploys the corresponding Huff contract, returning the address that the bytecode was deployed to. If you want, you can check out [how the HuffDeployer works under the hood](https://github.com/0xKitsune/Foundry-Huff/blob/main/lib/utils/HuffDeployer.sol). Below is a quick example of how to setup and deploy a SimpleStore contract written in Huff.


## SimpleStore.huff

Here is a simple Huff contract called `SimpleStore.huff`, which is stored within the `huff_contracts` directory. Make sure to put all of your `.huff` files in the `huff_contracts` directory so that the Huff compiler knows where to look when compiling.

```js
/* Storage Slots */
#define constant VAL_LOCATION = FREE_STORAGE_POINTER()

/* Constructor */
#define macro CONSTRUCTOR() = takes(0) returns (0) {}

//Get the value from storage
#define macro GET() = takes (0) returns (1) {
    [VAL_LOCATION] sload 0x00 mstore
    0x20 0x00 return
}

//Update the value in storage
#define macro STORE() = takes (1) returns (0) {
    [VAL_LOCATION] sstore
}


// Main Macro
#define macro MAIN() = takes(0) returns (0) {
    // Identify which function is being called.
    0x00 calldataload 0xE0 shr
    dup1 0xa9059cbb eq get jumpi
    dup1 0x6d4ce63c eq store jumpi

    get:
        GET()
    store:
        STORE()
}
```

<br>


## SimpleStore Interface

Next, you will need to create an interface for your contract. This will allow Foundry to interact with your Huff contract, enabling the full testing capabilities that Foundry has to offer.

```js

interface SimpleStore {
    function store(uint256 val) external;
    function get() external returns (uint256);
}
```

<br>


## SimpleStore Test

First, the file imports `ISimpleStore.sol` as well as the `HuffDeployer.sol` contract.

To deploy the contract, simply create a new instance of `HuffDeployer` and call `huffDeployer.deployContract(fileName)` method, passing in the file name of the contract you want to deploy. In this example, `SimpleStore` is passed in to deploy the `SimpleStore.huff` contract. The `deployContract` function compiles the Huff contract and deploys the newly compiled bytecode, returning the address that the contract was deployed to.

The deployed address is then used to initialize the ISimpleStore interface. Once the interface has been initialized, your Huff contract can be used within Foundry like any other Solidity contract.

To test any Huff contract deployed with HuffDeployer, simply run `forge test`. Since `ffi` is set to `true` in the `foundry.toml` file, you can run `forge test` without needing to pass in the `--ffi` flag. You can also use additional flags as you would with any other Foundry project. For example: `forge test -f <url> -vvvv`.

```js
import "../../lib/ds-test/test.sol";
import "../../lib/utils/HuffDeployer.sol";

import "../ISimpleStore.sol";

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

```


<br>

# Other Foundry Integrations

- [Foundry-Yul+](https://github.com/ControlCplusControlV/Foundry-Yulp) 
- [Foundry-Vyper](https://github.com/0xKitsune/Foundry-Vyper)

