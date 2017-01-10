#!/bin/bash

# This script creates a new Virtualbox VM in current folder with following default settings:
# - 4GB memory
# - 40GB same name vdi
# - cert folder: ../certs
# - iso: ~/iso/ubuntu-16.04.1-desktop-amd64.iso

VM_MEM=4096
VM_HDD=40000
CERT_DIR="../certs"
ISO_FILE="~/iso/ubuntu-16.04.1-desktop-amd64.iso"

if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
  echo "fatal: bad arguments\r\nUsage: command vmname ssh_port rdp_port"
  exit
fi

VM_NAME="$1"
VM_SSH_PORT=$2
VM_RDP_PORT=$3

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -m|--memory)
    VM_MEM=$2
    shift # past argument
    ;;
    -d|--hdd)
    VM_HDD=$2
    shift # past argument
    ;;
    -c|--cert)
    CERT_DIR="$2"
    shift # past argument
    ;;
    -i|--iso)
    ISO_FILE="$2"
    ;;
    *)
    # unknown option
    ;;
esac
shift # past argument or value
done


# Basic configuration
VBoxManage createvm --name "$VM_NAME" --ostype Linux_64 --register
VBoxManage modifyvm "$VM_NAME" --memory $VM_MEM --acpi on --boot1 dvd --nic1 nat
cd "$VM_NAME"
VBoxManage createhd --filename "$VM_NAME.vdi" --size $VM_HDD
VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "$VM_NAME.vdi"
VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium $ISO_FILE

# Network
VBoxManage modifyvm "$VM_NAME" --natpf1 "guestssh,tcp,,$VM_SSH_PORT,,22"

# Remote desktop
VBoxManage setproperty vrdeauthlibrary "VBoxAuthSimple"
VBoxManage modifyvm "$VM_NAME" --vrde on
VBoxManage modifyvm "$VM_NAME" --vrdemulticon on
VBoxManage modifyvm "$VM_NAME" --vrdeport $VM_RDP_PORT
VBoxManage modifyvm "$VM_NAME" --vrdeauthtype external
VBoxManage setextradata "$VM_NAME" "VBoxAuthSimple/users/hung" 60ba7ff9cb21414f8a23de131b2cb8a41fc4d64b2c0b8855dfea797da9bd5a6e

vboxmanage modifyvm "$VM_NAME" --vrdeproperty "Security/Method=negotiate"
vboxmanage modifyvm "$VM_NAME" --vrdeproperty "Security/CACertificate=$CERT_DIR/ca_cert.pem"
vboxmanage modifyvm "$VM_NAME" --vrdeproperty "Security/ServerCertificate=$CERT_DIR/server_cert.pem"
vboxmanage modifyvm "$VM_NAME" --vrdeproperty "Security/ServerPrivateKey=$CERT_DIR/server_key_private.pem"

# Start VM - non blocking
VBoxManage startvm "$VM_NAME" --type headless