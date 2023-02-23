#! /bin/bash

is_installed_npm() {
  command -v npm &> /dev/null
}

is_installed_yarn() {
  command -v yarn &> /dev/null
}

if is_installed_npm && ! [[ "$(npm list -g huffc)" =~ "empty" ]]; then
  # huffc was installed via npm, return 0x00
  echo -n 0x00
elif is_installed_yarn && [[ "$(yarn global list)" =~ "huffc" ]]; then
  # huffc was installed via yarn, return 0x00
  echo -n 0x00
else
  echo -n 0x01
fi
