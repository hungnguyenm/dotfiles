function git_clone_private() {
  mkdir -p $PRIVATE_FOLDER
  rm -rf $PRIVATE_FOLDER
  git clone $PRIVATE_GIT $PRIVATE_FOLDER
}

function git_remove_private() {
  rm -rf $PRIVATE_FOLDER
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