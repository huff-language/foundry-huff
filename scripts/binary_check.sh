#! /bin/bash

# Check if npm is installed
if command -v npm &> /dev/null; then
  if ! [[ "$(npm list -g huffc 2> /dev/null)" =~ "empty" ]]; then
    # huffc was installed via npm, return 0x00
    echo -n 0x00
    exit 0
  fi 
fi

# Check if yarn is installed
if command -v yarn &> /dev/null; then
  if [[ "$(yarn global list 2> /dev/null)" =~ "huffc" ]]; then
    # huffc was installed via yarn, return 0x00
    echo -n 0x00
    exit 0
  fi 
fi

# Else, return 0x01
echo -n 0x01
