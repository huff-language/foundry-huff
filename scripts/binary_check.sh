#! /bin/bash

if ! [[ "$(npm list -g huffc 2> /dev/null)" =~ "empty" ]]; then
  # huffc was installed via npm, return 0x00
  echo -n 0x00
elif [[ "$(yarn global list 2> /dev/null)" =~ "huffc" ]]; then
  # huffc was installed via yarn, return 0x00
  echo -n 0x00
else
  echo -n 0x01
fi
