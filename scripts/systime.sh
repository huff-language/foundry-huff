#! /bin/bash

# echo -n 0x`date +%s%N`
# echo -n 0x`node -e 'console.log(Date.now())'`
# echo -n 0x$(shuf -i 1-1000000000 -n 1)
echo -n $(hexdump -n 16 -v -e '"0x" 32/1 "%02x" "\n"' /dev/urandom)