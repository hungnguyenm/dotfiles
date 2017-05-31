function git_clone_private() {
  mkdir -p $PRIVATE_FOLDER
  rm -rf $PRIVATE_FOLDER
  git clone $PRIVATE_GIT $PRIVATE_FOLDER
}

function git_remove_private() {
  rm -rf $PRIVATE_FOLDER
}

function virsh_get_mac() {
  echo $(virsh dumpxml --domain "$1" | sed -ne "s/.*\([0-9a-fA-F:]\{17\}\).*/\1/p" 2> /dev/null)
}

function virsh_get_ip() {
  _mac_addr=$(virsh_get_mac "$1")
  echo $(virsh net-dumpxml --network default | sed -ne "s/.*$_mac_addr.*\([0-9]\{3\}\.[0-9]\{3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/p")
}

function iptables_dpt_map() {
  case "$1" in
    22) echo "ssh"
      ;;
    69) echo "tftp"
      ;;
    80) echo "http"
      ;;
    443) echo "https"
      ;;
    *) echo "$1"
      ;;
  esac
}

function guest_clear_cache() {
  sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
}