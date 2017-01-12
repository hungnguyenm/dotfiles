# clipboard
function xcopy() { xsel --clipboard < "$*"; }
function xover() { xsel --clipboard > "$*"; }
function xpaste() { xsel --clipboard >> "$*"; }

[ -r ~/.ssh/config ] && _ssh_config=($(cat ~/.ssh/config | sed -ne 's/Host[=/t ]\([^\*]\)/\1/p')) || _ssh_config=()

# sshfs functions
function fs() {
  if [[ -r ~/.ssh/config ]]; then
  	if [[ -n "$1" ]] && [[ $_ssh_config =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
      echo "Mounting remote host "$1":"$2""
      mkdir -p ~/remote/"$1"
      if [[ -n "$2" ]] ; then
        sshfs "$1":"$2" ~/remote/"$1"
      else
        sshfs "$1": ~/remote/"$1"
      fi
    else
      echo "fatal: fs only works with hosts defined in ~/.ssh/config\n\rUsage: fs host OR fs host path"
    fi
  else
  	echo "fatal: ~/.ssh/config doesn't exist"
  fi
}

function fsu() {
  if [[ -r ~/.ssh/config ]]; then
  	if [[ -n "$1" ]] && [[ $_ssh_config =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
      echo "Unmounting remote host "$1""
      case `uname` in
        Darwin) umount ~/remote/"$1"
          ;;
        Linux) fusermount -u ~/remote/"$1"
          ;;
      esac
    else
      echo "fatal: fsu only works with hosts defined in ~/.ssh/config\n\rUsage: fsu host"
    fi
  else
  	echo "fatal: ~/.ssh/config doesn't exist"
  fi
}

function fsc() {
  if [[ -r ~/.ssh/config ]]; then
  	if [[ -n "$1" ]] && [[ $_ssh_config =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
      cd ~/remote/"$1"
    else
      echo "fatal: fsc only works with hosts defined in ~/.ssh/config\n\rUsage: fsc host"
    fi
  else
  	echo "fatal: ~/.ssh/config doesn't exist"
  fi
}

function fsl() {
  mount | sed -ne 's/\(\/remote\/\)/\1/p'
}

function fso() {
  if [[ -n "$1" ]]; then
    if ! (mount | grep remote/"$1" > /dev/null); then
      if [[ -n "$2" ]]; then
        fs "$1" "$2"
      else
        fs "$1"
      fi
    fi

    case `uname` in
      Darwin)
        ofd ~/remote/"$1"
        ;;
      Linux)
        nautilus ~/remote/"$1"
        ;;
    esac
  else
    echo "Usage: fso host OR fso host path"
  fi
}

# improved ssh to send client host name env variable
function ssh() {
  if (( ${#} == 1 )); then
  	if [[ $_ssh_config =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
  	  command ssh -t "$1" "SSH_CLIENT_SHORT_HOST="${PREFER_HOST_NAME:-${SHORT_HOST}}" '$SHELL'"
  	else
  	  command ssh "$@"
  	fi
  else
  	command ssh "$@"
  fi
}

compctl -k "($_ssh_config)" fs fsu fsc fso

# virtualbox functions
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
  if [[ -n "$1" ]]; then
    if [[ $(vbm list runningvms | egrep -c "$1") -gt 0 ]]; then
      VBoxManage controlvm "$1" poweroff
    fi
    VBoxManage unregistervm "$1" --delete
  else
    echo "Usage: vbm-delete vmname"
  fi
}

# private configuration
function config-test() {
  git_clone_private
  $PRIVATE_FOLDER/echo.sh
  git_remove_private
}

_ssh_profile="ubuntu-desktop ubuntu-server debian-embedded"
function config-ssh() {
  if [[ -n "$1" ]] && [[ $_ssh_profile =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    git_clone_private
    $PRIVATE_FOLDER/scripts/ssh/"$1".zsh
    git_remove_private
  else
    echo "fatal: invalid profile"
  fi
}

function config-ssh-restart() {
  if [[ -n $(strings /sbin/init | grep "/lib/systemd" 2> /dev/null) ]]; then
    sudo systemctl restart ssh
  else
    sudo /etc/init.d/ssh restart
  fi
}

_firewall_profile="default server erx-local"
function config-firewall() {
  if [[ -n "$1" ]] && [[ $_firewall_profile =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    git_clone_private
    source $PRIVATE_FOLDER/scripts/firewall/"$1".zsh
    git_remove_private
  else
    echo "fatal: invalid profile"
  fi
}

_config_profile="firewall"
function config-show() {
  if [[ -n "$1" ]] && [[ $_firewall_profile =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    case "$1" in
      firewall)
        echo "IPv4 Configuration:\n\r"
        sudo iptables -L -v
        echo "\n\rIPv6 Configuration:\n\r"
        sudo ip6tables -L -v
        ;;
      *) echo "nah"
        ;;
    esac
  else
    echo "fatal: invalid profile"
  fi
}

compctl -k "($_ssh_profile)" config-ssh
compctl -k "($_firewall_profile)" config-firewall
compctl -k "($_config_profile)" config-show

# helper functions
function git_clone_private() {
  mkdir -p $PRIVATE_FOLDER
  rm -rf $PRIVATE_FOLDER
  git clone $PRIVATE_GIT $PRIVATE_FOLDER
}

function git_remove_private() {
  rm -rf $PRIVATE_FOLDER
}