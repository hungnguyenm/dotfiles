#!/usr/bin/env bash

# Returns VNC info

type virsh > /dev/null
_function_not_exists=$?

if (( $_function_not_exists == 0 )); then
  virsh list --state-running --name | while read i; do
  	[[ -z $i ]] && continue
  	echo "$i:"
    virsh vncdisplay --domain "$i" | sed -e "s/\(127.0.0.1\)/vnc - \1/g"
  done
fi