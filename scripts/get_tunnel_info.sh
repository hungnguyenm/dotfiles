#!/usr/bin/env bash

# Returns VNC info

type virsh > /dev/null
_function_not_exists=$?

if (( $_function_not_exists == 0 )); then
  _vm_list=$(virsh list --state-running --name)
  for i in "$_vm_list"; do
  	echo "$i:"
    virsh vncdisplay --domain $i | sed -e "s/\(127.0.0.1\)/vnc - \1/g"
  done
fi