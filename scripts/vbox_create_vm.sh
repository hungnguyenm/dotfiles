#!/usr/bin/env bash

# This script creates a new Virtualbox VM in current folder with following default settings:
# - 4GB memory
# - 40GB same name vdi
# - cert folder: certs
# - iso: iso/ubuntu-16.04.1-desktop-amd64.iso

VM_MEM=4096
VM_HDD=40000
CERT_DIR="certs"
ISO_FILE="iso/ubuntu-16.04.1-desktop-amd64.iso"

if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]] || [[ -z "$4" ]]; then
  echo "fatal: bad arguments\r\nUsage: command vmname ssh_port rdp_port rdp_pass"
  exit
fi

VM_NAME="$1"
shift
VM_SSH_PORT=$1
shift
VM_RDP_PORT=$1
shift
HASH_PASS="$(VBoxManage internalcommands passwordhash "secret" | sed -ne 's/Password hash: //p')"
shift

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
VBoxManage createhd --filename "$VM_NAME/$VM_NAME.vdi" --size $VM_HDD
VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "$VM_NAME/$VM_NAME.vdi"
VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium "$ISO_FILE"

# Network
VBoxManage modifyvm "$VM_NAME" --natpf1 "guestssh,tcp,,$VM_SSH_PORT,,22"

# Remote desktop
VBoxManage setproperty vrdeauthlibrary "VBoxAuthSimple"
VBoxManage modifyvm "$VM_NAME" --vrde on
VBoxManage modifyvm "$VM_NAME" --vrdemulticon on
VBoxManage modifyvm "$VM_NAME" --vrdeport $VM_RDP_PORT
VBoxManage modifyvm "$VM_NAME" --vrdeauthtype external
VBoxManage setextradata "$VM_NAME" "VBoxAuthSimple/users/hung" "$HASH_PASS"

vboxmanage modifyvm "$VM_NAME" --vrdeproperty "Security/Method=negotiate"
vboxmanage modifyvm "$VM_NAME" --vrdeproperty "Security/CACertificate=$CERT_DIR/ca_cert.pem"
vboxmanage modifyvm "$VM_NAME" --vrdeproperty "Security/ServerCertificate=$CERT_DIR/server_cert.pem"
vboxmanage modifyvm "$VM_NAME" --vrdeproperty "Security/ServerPrivateKey=$CERT_DIR/server_key_private.pem"

# Start VM - non blocking
VBoxManage startvm "$VM_NAME" --type headless