# Foundry x Huff

A Foundry template to compile and test Huff contracts.

```
                                       WX0o;'......';cd0N                                
                                     Nkc,....','...   .,kN                              
                                    Nk:'..   ......   'xN                               
                                   Xl'...   .         .:K                                
                                   0c,'..  ....     ....oN                            
                                  No...   .;l,.   . ..,.:K                              
                                  Nd;,.  .,l;.   .      .lX                           
                                  Wx'... .;:.......    . .cKW                            
                                  Wk:,.. .',...':lc;'..   .cX                            
                                   No...  .....':lxKXO:...'xW                            
                                   Wd''..  ..  .';:okXNK0O0W                           
                                    Xl...    .  ...;clxX                               
                                    Wd...          .,l::OW                              
                                     Kl:'           .;d,'kW                           
                                     WKc.        .  .'c,.cX                             
                                      Kc.            ...:OW                             
                                       Xl.     .       ;0                                
                                       WOl:;;;;;;;;;;;cxN                                
                                        0c'''',:llllcxN                                 
                                        Kc.     ......,kW                                
                                      Nk;...............oX                               
                                    WXkl;;;;;:;;;;;;:cllokKN                             
                                  W0c'...............;;;;;';xN                          
                                  Nx,,,,,,,,,,,,,,,,,,,,,,,,cK                           
                                ██   ██ ██    ██ ███████ ███████
                                ██   ██ ██    ██ ██      ██
                                ███████ ██    ██ █████   █████
                                ██   ██ ██    ██ ██      ██
                                ██   ██  ██████  ██      ██
```

<br>

# Installation

First, install the [huff compiler](https://github.com/huff-language/huff-rs) by running:
```
curl -L get.huff.sh | bash
```

Then, install this library with [forge](https://github.com/foundry-rs/foundry):
```
forge install huff-language/foundry-huff
```


# Usage

The HuffDeployer is a pre-built contract that takes a filename and deploys the corresponding Huff contract, returning the address that the bytecode was deployed to. To use it, simply import it into your file by doing:

```js
import { HuffDeployer } from "foundry-huff/HuffDeployer.sol";
```

To actually compile contracts, you can use `HuffDeployer.deploy(string fileName)`, which takes in a single string representing the filename's path relative to the `src` directory. Here is an example deployment contract:

```js
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../HuffDeployer.sol";

contract HuffDeployerTest {
    HuffDeployer huffDeployer = new HuffDeployer();

    function deploy() public {
        ///@notice deploy a new instance of ISimplestore by passing in the address of the deployed Huff contract
        address addr = huffDeployer.deploy("test/contracts/Number");
    }
}
```
