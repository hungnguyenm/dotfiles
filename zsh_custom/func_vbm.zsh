function vbm-poweroff() {
  VBoxManage controlvm "$1" poweroff
}

function vbm-reset() {
  VBoxManage controlvm "$1" reset
}

function vbm-shutdown() {
  VBoxManage controlvm "$1" shutdown
}

function vbm-start-headless() {
  VBoxManage startvm "$1" --type headless
}

function vbm-delete() {
  if [[ -n $1 ]]; then
    if [[ $(vbm list runningvms | egrep -c "$1") -gt 0 ]]; then
      VBoxManage controlvm "$1" poweroff
    fi
    VBoxManage unregistervm "$1" --delete
  else
    echo "Usage: vbm-delete vmname"
  fi
}