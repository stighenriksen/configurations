#!/usr/bin/env sh
  
cd "$( dirname "${BASH_SOURCE[0]}" )"

sudo nix-channel --update
./rebuild.sh
