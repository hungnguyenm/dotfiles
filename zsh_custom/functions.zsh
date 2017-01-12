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

# virsh functions
function virsh-wget-iso() {
  sudo wget "$1" --directory-prefix="/var/lib/libvirt/boot/"
}

function virsh-restart() {
  sudo /etc/init.d/libvirt-bin restart
}

function virsh-network-restart() {
  _net_names=$(sudo virsh net-list --all | grep -Eo '^ [^ ]*' | grep -v 'Name' | tr -d " ")
  for i in "$_net_names"; do
    sudo virsh net-destroy $i 
    sudo virsh net-start $i
  done
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
    $PRIVATE_FOLDER/scripts/firewall/"$1".zsh
    git_remove_private
  else
    echo "fatal: invalid profile"
  fi
}

function config-firewall-nat-add() {
  if [[ -n "$1" ]] && [[ -n "$2" ]] && [[ -n "$3" ]]; then
    # backup
    mkdir -p $DOTFILES_DIR/local/iptables
    sudo iptables-save >! $DOTFILES_DIR/local/iptables/rules.old.v4
    sudo ip6tables-save >! $DOTFILES_DIR/local/iptables/rules.old.v6

    sudo iptables -t nat -D PREROUTING -p tcp --dport $2 -j DNAT --to-destination $1:$3 2> /dev/null
    sudo iptables -t nat -A PREROUTING -p tcp --dport $2 -j DNAT --to-destination $1:$3
    sudo iptables -D FORWARD -d $1 -p tcp -m state --state NEW -m tcp --dport $3 -j ACCEPT 2> /dev/null
    sudo iptables -I FORWARD -d $1 -p tcp -m state --state NEW -m tcp --dport $3 -j ACCEPT

    # backup
    sudo iptables-save >! $DOTFILES_DIR/local/iptables/rules.v4
    sudo ip6tables-save >! $DOTFILES_DIR/local/iptables/rules.v6
  else
    echo "fatal: bad arguments"
  fi
}

function config-firewall-nat-delete() {
  if [[ -n "$1" ]] && [[ -n "$2" ]] && [[ -n "$3" ]]; then
    # backup
    mkdir -p $DOTFILES_DIR/local/iptables
    sudo iptables-save >! $DOTFILES_DIR/local/iptables/rules.old.v4
    sudo ip6tables-save >! $DOTFILES_DIR/local/iptables/rules.old.v6

    sudo iptables -t nat -D PREROUTING -p tcp --dport $2 -j DNAT --to-destination $1:$3
    sudo iptables -I FORWARD -d $1 -p tcp -m state --state NEW -m tcp --dport $3 -j ACCEPT

    # backup
    sudo iptables-save >! $DOTFILES_DIR/local/iptables/rules.v4
    sudo ip6tables-save >! $DOTFILES_DIR/local/iptables/rules.v6
  else
    echo "fatal: bad arguments"
  fi
}

_config_profile="firewall"
function config-show() {
  if [[ -n "$1" ]] && [[ $_config_profile =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    case "$1" in
      firewall)
        echo "IPv4 CONFIG:\n\r"
        sudo iptables -L -v

        echo "\n\rIPv4 NAT CONFIG:\n\r"
        sudo iptables -L -vt nat

        echo "\n\rIPv6 CONFIG:\n\r"
        sudo ip6tables -L -v

        # backup
        mkdir -p $DOTFILES_DIR/local/iptables
        sudo iptables-save >! $DOTFILES_DIR/local/iptables/rules.v4
        sudo ip6tables-save >! $DOTFILES_DIR/local/iptables/rules.v6
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

# backup
function backup-local() {
  git_clone_private
  _now=`date +%Y-%m-%d_%H-%M-%S`
  mkdir -p "$PRIVATE_FOLDER/backup/local/$SHORT_HOST/$_now"
  cp -r $DOTFILES_DIR/local/* $PRIVATE_FOLDER/backup/local/$SHORT_HOST/$_now
  cd $PRIVATE_FOLDER/backup/local/$SHORT_HOST/$_now
  git add --all --force
  cd $PRIVATE_FOLDER
  git commit -a -m "back up local from $SHORT_HOST"
  git push
  cd -2
  git_remove_private
}

# helper functions
function git_clone_private() {
  mkdir -p $PRIVATE_FOLDER
  rm -rf $PRIVATE_FOLDER
  git clone $PRIVATE_GIT $PRIVATE_FOLDER
}

function git_remove_private() {
  rm -rf $PRIVATE_FOLDER
}