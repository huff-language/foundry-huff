#! /bin/bash

check_cmd() {
  command -v "$1" > /dev/null 2>&1
}

if check_cmd npm && ! [[ "$(npm list -g huffc)" =~ "empty" ]]; then
  # huffc was installed via npm, return 0x00
  echo -n 0x00
elif check_cmd yarn && [[ "$(yarn global list)" =~ "huffc" ]]; then
  # huffc was installed via yarn, return 0x00
  echo -n 0x00
else
  echo -n 0x01
fi
