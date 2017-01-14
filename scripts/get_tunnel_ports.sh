#!/usr/bin/env bash

# Returns list of running VNC ports

type virsh > /dev/null
_function_not_exists=$?

if (( $_function_not_exists == 0 )); then
  virsh list --state-running --name | while read i; do
  	[[ -z $i ]] && continue
    virsh vncdisplay --domain "$i" | sed -ne "s/^.*127.0.0.1:\([0-9]\)/590\1/p;s/^.*127.0.0.1:\([0-9][0-9]\)/59\1/p" | grep  .[0-9]*
  done
fi