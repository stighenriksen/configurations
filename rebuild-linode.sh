#!/usr/bin/env sh

rsync --filter="protect /hardware-configuration.nix" \
     --filter="protect /hostname" \
     --filter="protect /nixpkgs" \
     --filter="protect /private" \
     --filter="protect /release" \
     --filter="exclude,s *.gitignore" \
     --filter="exclude,s *.gitmodules" \
     --filter="exclude,s *.git" \
     --filter="exclude .*.swp" \
     --filter="exclude Session.vim" \
     --delete --recursive --perms \
     ./machines/linode/ linode:/home/stig/nixosconfig/

if [ $# -eq 0 ]; then
    operation='switch'
else
    operation=$1
fi
cd $wd
ssh -t nixlinode sudo rsync -r /home/stig/nixosconfig/* /etc/nixos/; ssh -t linode sudo NIX_CURL_FLAGS='--retry=1000' nixos-rebuild --keep-failed $operation
