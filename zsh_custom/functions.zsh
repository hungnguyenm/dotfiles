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

_virsh_network_profile="default"
function virsh-config-default-network() {
  if [[ -n "$1" ]] && [[ $_virsh_network_profile =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    git_clone_private
    sudo virsh net-define $PRIVATE_FOLDER/libvirt/network_"$1".xml
    sudo virsh net-autostart --network "$1"
    sudo virsh net-destroy "$1"
    sudo virsh net-start "$1"
    git_remove_private
  else
    echo "fatal: invalid profile"
  fi
}
compctl -k "($_virsh_network_profile)" virsh-config-default-network

function virsh-config-network() {
  if [[ -n "$1" ]]; then
    sudo virsh net-define "$1"
    virsh-network-restart
  else
    echo "fatal: bad argument"
  fi
}

function virsh-config-staticip() {
  _vm_list=$(virsh list --all --name)
  if [[ -n "$1" ]] && [[ $_vm_list =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    _mac_addr=$(virsh dumpxml --domain "$1" | sed -ne "s/.*\([0-9a-fA-F:]\{17\}\).*/\1/p" 2> /dev/null)

    # Export file to edit
    mkdir -p $DOTFILES_DIR/backup/libvirt
    virsh net-dumpxml --network default >! $DOTFILES_DIR/backup/libvirt/network_default.xml
    /bin/cp -rf $DOTFILES_DIR/backup/libvirt/network_default.xml $DOTFILES_DIR/backup/libvirt/network_default.old.xml

    # Check if IP is already assigned
    if sed -e "/$_mac_addr/d" $DOTFILES_DIR/backup/libvirt/network_default.xml | grep -Fq "$2"; then
      echo "fatal: IP is already assigned"
    else
      # Update config
      if grep -Fq "$_mac_addr" $DOTFILES_DIR/backup/libvirt/network_default.xml; then
        # MAC address exists
        sed -i "/$_mac_addr/d" $DOTFILES_DIR/backup/libvirt/network_default.xml
      fi
      sed -i "/range start/a \ \ \ \ \ \ <host mac='$_mac_addr' name='$1' ip='$2'\/>" $DOTFILES_DIR/backup/libvirt/network_default.xml

      # Load config
      sudo virsh net-define $DOTFILES_DIR/backup/libvirt/network_default.xml
      sudo virsh net-autostart --network default
      sudo virsh net-destroy default
      sudo virsh net-start default

      echo "Static IP $2 is assigned for $1!"
    fi
  else
    echo "fatal: vm name is not valid"
    echo "Usage: virsh-config-staticip vmname staticip"
  fi
}

function virsh-config-nat() {
  _vm_list=$(virsh list --all --name)
  if [[ -n "$2" ]] && [[ -n "$3" ]]; then
    if [[ -n "$1" ]] && [[ $_vm_list =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
      _mac_addr=$(virsh dumpxml --domain "$1" | sed -ne "s/.*\([0-9a-fA-F:]\{17\}\).*/\1/p" 2> /dev/null)
      _ip_addr=$(virsh net-dumpxml --network default | sed -ne "s/.*$_mac_addr.*\([0-9]\{3\}\.[0-9]\{3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/p")

      if [[ -n "$_ip_addr" ]]; then
        config-firewall-nat-add "$_ip_addr" "$2" "$3"
        echo "Added NAT from port $2 to $_ip_addr:$3"
      else
        echo "fatal: vm doesn't have static ip"
      fi
    else
      echo "fatal: vm name is not valid"
      echo "Usage: virsh-config-nat vmname hostport guestport"
    fi
  else
    echo "fatal: bad arguments"
    echo "Usage: virsh-config-nat vmname hostport guestport"
  fi
}

_virsh_config_profile="network"
function virsh-config-show() {
  if [[ -n "$1" ]] && [[ $_virsh_config_profile =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    case "$1" in
      network)
        _net_names=$(virsh net-list --all | grep -Eo '^ [^ ]*' | grep -v 'Name' | tr -d " ")
        for i in "$_net_names"; do
          virsh net-dumpxml --network $i >! $DOTFILES_DIR/backup/libvirt/network_$i.xml
          virsh net-dumpxml --network $i
          echo "\r\n"
        done
        ;;
      *) echo "nah"
        ;;
    esac
  else
    echo "fatal: invalid profile"
  fi
}
compctl -k "($_virsh_config_profile)" virsh-config-show

function virsh-network-restart() {
  _net_names=$(sudo virsh net-list --all | grep -Eo '^ [^ ]*' | grep -v 'Name' | tr -d " ")
  for i in "$_net_names"; do
    sudo virsh net-destroy $i 
    sudo virsh net-start $i
  done
}

function virsh-dev() {
  _vm_list=$(virsh list --all --name)
  _mac_addr=$(virsh dumpxml --domain $_vm_list | sed -ne "s/.*\([0-9a-fA-F:]\{17\}\).*/\1/p" 2> /dev/null)
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
compctl -k "($_ssh_profile)" config-ssh

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
compctl -k "($_firewall_profile)" config-firewall

function config-firewall-nat-add() {
  if [[ -n "$1" ]] && [[ -n "$2" ]] && [[ -n "$3" ]]; then
    # backup
    mkdir -p $DOTFILES_DIR/backup/iptables
    sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v4
    sudo ip6tables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v6

    sudo iptables -t nat -D PREROUTING -p tcp --dport $2 -j DNAT --to-destination $1:$3 2> /dev/null
    sudo iptables -t nat -A PREROUTING -p tcp --dport $2 -j DNAT --to-destination $1:$3
    sudo iptables -D FORWARD -d $1 -p tcp -m state --state NEW -m tcp --dport $3 -j ACCEPT 2> /dev/null
    sudo iptables -I FORWARD -d $1 -p tcp -m state --state NEW -m tcp --dport $3 -j ACCEPT

    # backup
    sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.v4
    sudo ip6tables-save >! $DOTFILES_DIR/backup/iptables/rules.v6
  else
    echo "fatal: bad arguments"
    echo "Usage: config-firewall-nat-add new_ip old_port new_port"
  fi
}

function config-firewall-nat-delete() {
  if [[ -n "$1" ]] && [[ -n "$2" ]] && [[ -n "$3" ]]; then
    # backup
    mkdir -p $DOTFILES_DIR/backup/iptables
    sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v4
    sudo ip6tables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v6

    sudo iptables -t nat -D PREROUTING -p tcp --dport $2 -j DNAT --to-destination $1:$3
    sudo iptables -I FORWARD -d $1 -p tcp -m state --state NEW -m tcp --dport $3 -j ACCEPT

    # backup
    sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.v4
    sudo ip6tables-save >! $DOTFILES_DIR/backup/iptables/rules.v6
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
        mkdir -p $DOTFILES_DIR/backup/iptables
        sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.v4
        sudo ip6tables-save >! $DOTFILES_DIR/backup/iptables/rules.v6
        ;;
      *) echo "nah"
        ;;
    esac
  else
    echo "fatal: invalid profile"
  fi
}
compctl -k "($_config_profile)" config-show

# backup
function backup-backup() {
  git_clone_private
  _now=`date +%Y-%m-%d_%H-%M-%S`
  mkdir -p "$PRIVATE_FOLDER/backup/backup/$SHORT_HOST/$_now"
  cp -r $DOTFILES_DIR/backup/* $PRIVATE_FOLDER/backup/backup/$SHORT_HOST/$_now
  cd $PRIVATE_FOLDER/backup/backup/$SHORT_HOST/$_now
  git add --all --force .
  cd $PRIVATE_FOLDER
  git commit -a -m "back up backup from $SHORT_HOST"
  git push
  cd -2
  git_remove_private
}

function backup-local() {
  git_clone_private
  _now=`date +%Y-%m-%d_%H-%M-%S`
  mkdir -p "$PRIVATE_FOLDER/backup/local/$SHORT_HOST/$_now"
  cp -r $DOTFILES_DIR/local/* $PRIVATE_FOLDER/backup/local/$SHORT_HOST/$_now
  cd $PRIVATE_FOLDER/backup/local/$SHORT_HOST/$_now
  git add --all --force .
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