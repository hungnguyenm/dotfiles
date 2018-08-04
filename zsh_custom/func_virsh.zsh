function virsh-wget-iso() {
  sudo wget "$1" --directory-prefix="/var/lib/libvirt/boot/"
}

function virsh-restart() {
  sudo /etc/init.d/libvirt-bin restart
}

function virsh-convert-vmdk-qcow2() {
  # merge and convert all vmdk files in current folder to desired file name qcow2
  if [[ -n $1 ]]; then
    for i in *.vmdk; do qemu-img convert -f vmdk $i -O raw $i.raw; done
    cat *.raw > tmpImage.raw
    qemu-img convert tmpImage.raw "$1.qcow2"
    rm *.raw
  else
    echo "fatal: please provide output file name without extension"
  fi
}

# helper functions
function virsh_get_mac() {
  echo $(virsh dumpxml --domain "$1" | sed -ne "s/.*\([0-9a-fA-F:]\{17\}\).*/\1/p" 2> /dev/null)
}

function virsh_get_ip() {
  _mac_addr=$(virsh_get_mac "$1")
  echo $(virsh net-dumpxml --network default | sed -ne "s/.*$_mac_addr.*\([0-9]\{3\}\.[0-9]\{3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/p")
}