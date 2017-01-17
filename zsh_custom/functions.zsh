# clipboard
function xcopy() { xsel --clipboard < "$*"; }
function xover() { xsel --clipboard > "$*"; }
function xpaste() { xsel --clipboard >> "$*"; }

[ -r ~/.ssh/config ] && _ssh_config=($(cat ~/.ssh/config | sed -ne 's/Host[=/t ]\([^\*]\)/\1/p')) || _ssh_config=()

# sshfs functions
function fs() {
  if [[ -r ~/.ssh/config ]]; then
  	if [[ -n $1 ]] && [[ $_ssh_config =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
      echo "Mounting remote host "$1":"$2""
      mkdir -p ~/remote/"$1"
      if [[ -n $2 ]] ; then
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
  	if [[ -n $1 ]] && [[ $_ssh_config =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
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
  	if [[ -n $1 ]] && [[ $_ssh_config =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
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
  if [[ -n $1 ]]; then
    if ! (mount | grep remote/"$1" > /dev/null); then
      if [[ -n $2 ]]; then
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
  	if [[ $_ssh_config =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
  	  command ssh -t "$1" "SSH_CLIENT_SHORT_HOST="${PREFER_HOST_NAME:-${SHORT_HOST}}" '$SHELL'"
  	else
  	  command ssh "$@"
  	fi
  else
  	command ssh "$@"
  fi
}

function ssh-dotfiles() {
  ssh -t "$@" "sudo apt-get install -y git;rm -rf ~/dotfiles;git clone --recursive https://github.com/hungnguyenm/dotfiles ~/dotfiles"
  ssh "$@" -A
}

function ssh-tunnel() {
  if [[ -r ~/.ssh/config ]]; then
    if [[ -n $1 ]] && [[ $_ssh_config =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
      _port_list=$(ssh "$1" 'bash -s' < $DOTFILES_DIR/scripts/get_tunnel_ports.sh)
      if [[ -n "_port_list" ]]; then
        echo "Tunneling..."
        command ssh "$1" 'bash -s' < $DOTFILES_DIR/scripts/get_tunnel_info.sh | \
            sed -e "s/\(spice - \).*\(127.0.0.1:\)\([0-9]*\)/\1950\3 forward to \2590\3/g;s/\(vnc - \).*\(127.0.0.1:\)\([0-9]*\)/\1950\3 forward to \2590\3/g"
        _ssh_options=$1
        while read i; do
          [[ -z $i ]] && continue
          nc -z localhost "95${i: -2}" 2> /dev/null && echo "Port 95${i: -2} is in used!" && return 1
          _ssh_options="$_ssh_options -L 95${i: -2}:localhost:$i"
        done <<< "$_port_list"
        command ssh $=_ssh_options -t "SSH_CLIENT_SHORT_HOST="${PREFER_HOST_NAME:-${SHORT_HOST}}-tunnel" '$SHELL'"
      else
        echo "No VNC port available!"
      fi
    else
      echo "fatal: ssh-tunnel only works with hosts defined in ~/.ssh/config\n\rUsage: ssh-tunnel host"
    fi
  else
    echo "fatal: ~/.ssh/config doesn't exist"
  fi
}
compctl -k "($_ssh_config)" fs fsu fsc fso ssh-tunnel

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
  if [[ -n $1 ]]; then
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

_virsh_network_profile="default"
function virsh-config-default-network() {
  if [[ -n $1 ]] && [[ $_virsh_network_profile =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
    _old_uuid=$(virsh net-dumpxml --network "$1" | sed -ne "s/.*<uuid>\(.*\)<\/uuid>.*/\1/p")
    git_clone_private
    if [[ -n $_old_uuid ]]; then
      sed -i "/<name>/a \ \ <uuid>$_old_uuid<\/uuid>" $PRIVATE_FOLDER/libvirt/network_"$1".xml
    fi
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
  if [[ -n $1 ]]; then
    sudo virsh net-define "$1"
    virsh-network-restart
  else
    echo "fatal: bad argument"
  fi
}

function virsh-config-staticip() {
  _vm_list=$(virsh list --all --name)
  if [[ -n $1 ]] && [[ $_vm_list =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
    _mac_addr=$(virsh_get_mac "$1")

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

function virsh-config-staticip-delete() {
  # Export file to edit
  mkdir -p $DOTFILES_DIR/backup/libvirt
  virsh net-dumpxml --network default >! $DOTFILES_DIR/backup/libvirt/network_default.xml
  /bin/cp -rf $DOTFILES_DIR/backup/libvirt/network_default.xml $DOTFILES_DIR/backup/libvirt/network_default.old.xml

  echo "Current config:"
  virsh net-dumpxml --network default

  read "_ip?What IP do you want to delete: "
  if [[ $_ip != ${_ip#*[0-9].[0-9]} ]]; then
    # Check if IP is already assigned
    if sed -ne "s/\(.*<host>.*\)\($_ip\)\(.*\)/\1\2\3/p" $DOTFILES_DIR/backup/libvirt/network_default.xml; then
      echo "Current host:"
      grep ".*<host.*$_ip.*" $DOTFILES_DIR/backup/libvirt/network_default.xml
      read -q "_confirm?Are you sure [yn]? "
      if [[ "$_confirm" =~ ^[Yy]$ ]]; then
        # Update config
        sed -i "/.*<host.*$_ip.*/d" $DOTFILES_DIR/backup/libvirt/network_default.xml

        # Load config
        echo "\r\n"
        sudo virsh net-define $DOTFILES_DIR/backup/libvirt/network_default.xml
        sudo virsh net-autostart --network default
        sudo virsh net-destroy default
        sudo virsh net-start default

        echo "Static IP $_ip is removed!"  
      else
        echo "\r\nAborted!"
      fi
    else
      echo "Static IP is not assigned!"
    fi
  else
    echo "fatal: invalid IP"
  fi
}

function virsh-config-nat-add() {
  _vm_list=$(virsh list --all --name)
  if [[ -n $2 ]] && [[ -n $3 ]]; then
    if [[ -n $1 ]] && [[ $_vm_list =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
      _ip_addr=$(virsh_get_ip "$1")

      if [[ -n $_ip_addr ]]; then
        config-firewall-nat-add "$_ip_addr" "$2" "$3"
        echo "Added NAT from port $2 to $_ip_addr:$3"
      else
        echo "fatal: vm doesn't have static ip"
      fi
    else
      echo "fatal: vm name is not valid"
      echo "Usage: virsh-config-nat vmname-add hostport guestport"
    fi
  else
    echo "fatal: bad arguments"
    echo "Usage: virsh-config-nat-add vmname hostport guestport"
  fi
}

function virsh-config-nat-delete() {
  _vm_list=$(virsh list --all --name)
  if [[ -n $2 ]]; then
    if [[ -n $1 ]] && [[ $_vm_list =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
      _ip_addr=$(virsh_get_ip "$1")

      if [[ -n $_ip_addr ]]; then
        _preroute_line=$(sudo iptables -L PREROUTING -t nat --line-numbers > /dev/null | sed -ne "s/^\([0-9]\)*\ .*$_ip_addr:$2/\1/p")
        _map_port=$(iptables_dpt_map $2)
        _forward_line=$(sudo iptables -L FORWARD --line-numbers | sed -ne "s/^\([0-9]\)*\ .*$_ip_addr.*dpt:$_map_port.*/\1/p")

        if [[ -n $_preroute_line ]] && ! [[ $_preroute_line =~ ( |\') ]]; then
          _host_port=$(sudo iptables -L PREROUTING -t nat --line-numbers | sed -ne "s/^\([0-9]\)*\ .*dpt:\([^\ ]*\).*$_ip_addr:$2/\2/p")

          mkdir -p $DOTFILES_DIR/backup/iptables
          sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v4

          sudo iptables -t nat -D PREROUTING $_preroute_line && echo "Deleted NAT PREROUTING from port $_host_port to $_ip_addr:$2"

          # Might missed FORWARD chain here, but it's okay
          if [[ -n $_forward_line ]] && ! [[ $_forward_line =~ ( |\') ]]; then
            sudo iptables -D FORWARD $_forward_line && echo "Deleted FORWARDING to $_ip_addr:$2"
          fi

          sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.v4
        else
          echo "No matched rule to delete!"
        fi
      else
        echo "fatal: vm doesn't have static ip"
      fi
    else
      echo "fatal: vm name is not valid"
      echo "Usage: virsh-config-nat-remove vmname guestport"
    fi
  else
    echo "fatal: bad arguments"
    echo "Usage: virsh-config-nat-remove vmname guestport"
  fi
}

_virsh_config_profile="network nat"
function virsh-config-show() {
  if [[ -n $1 ]] && [[ $_virsh_config_profile =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
    case "$1" in
      network)
        _net_names=$(virsh net-list --all | grep -Eo '^ [^ ]*' | grep -v 'Name' | tr -d " ")
        while read i; do
          [[ -z $i ]] && continue
          virsh net-dumpxml --network "$i" >! $DOTFILES_DIR/backup/libvirt/network_"$i".xml
          virsh net-dumpxml --network "$i"
          echo "\r\n"
        done <<< "$_net_names"
        ;;
      nat)
        _vm_list=$(virsh list --all --name)
        while read i; do
          [[ -z $i ]] && continue
          _ip_addr=$(virsh_get_ip "$i")
          if [[ -n $_ip_addr ]]; then
            echo "$i:"
            sudo iptables -L PREROUTING -t nat --line-numbers > /dev/null | \
                sed -ne "s/.*\(\(tcp\|udp\)\ dpt.*$_ip_addr.*\)/\1/p" | while read ii; do
              echo "$ii"
            done
          else
            echo "$i: no static IP assigned."
          fi
        done <<< "$_vm_list"
        ;;
      *) echo "oops!not implemented!"
        ;;
    esac
  else
    echo "fatal: invalid profile"
  fi
}
compctl -k "($_virsh_config_profile)" virsh-config-show

function virsh-config-backup() {
  mkdir -p $DOTFILES_DIR/backup/libvirt/qemu

  _now=`date +%Y-%m-%d_%H-%M-%S`
  echo "$SHORT_HOST -- $_now" | tee $DOTFILES_DIR/backup/libvirt/config.txt

  virsh list --all --name | while read i; do
    [[ -z $i ]] && continue
    _ip_addr=$(virsh_get_ip "$i")
    if [[ -n $_ip_addr ]]; then
      echo "$i: $_ip_addr" | tee -a $DOTFILES_DIR/backup/libvirt/config.txt
      sudo iptables -L PREROUTING -t nat --line-numbers > /dev/null | \
          sed -ne "s/.*\(\(tcp\|udp\)\ dpt.*$_ip_addr.*\)/\1/p" | while read ii; do
        echo "$ii" | tee -a $DOTFILES_DIR/backup/libvirt/config.txt
      done
    else
      echo "$i: no static IP\r\nNo NAT rule!" | tee -a $DOTFILES_DIR/backup/libvirt/config.txt
    fi
  done

  echo "\n\r" | tee -a $DOTFILES_DIR/backup/libvirt/config.txt
  virsh net-list --all | grep -Eo '^ [^ ]*' | grep -v 'Name' | tr -d " " | while read i; do
    virsh net-dumpxml --network $i | tee -a $DOTFILES_DIR/backup/libvirt/config.txt
    echo "\r\n"
  done

  virsh list --all --name | while read i; do
    [[ -z $i ]] && continue
    virsh dumpxml --domain "$i" > "$DOTFILES_DIR/backup/libvirt/qemu/$i.xml"
  done
}

function virsh-network-restart() {
  sudo virsh net-list --all | grep -Eo '^ [^ ]*' | grep -v 'Name' | tr -d " " | while read i; do
    sudo virsh net-destroy "$i"
    sudo virsh net-start "$i"
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
  if [[ -n $1 ]] && [[ $_ssh_profile =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
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
  if [[ -n $1 ]] && [[ $_firewall_profile =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
    git_clone_private
    $PRIVATE_FOLDER/scripts/firewall/"$1".zsh
    git_remove_private
  else
    echo "fatal: invalid profile"
  fi
}
compctl -k "($_firewall_profile)" config-firewall

_firewall_delete_profile="nat-prerouting input-forward"
function config-firewall-delete() {
  if [[ -n $1 ]] && [[ $_firewall_delete_profile =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
    case "$1" in
      nat-prerouting)
        sudo iptables -L PREROUTING -vt nat --line-numbers
        echo "\r\n"
        read "_line?What line do you want to delete: "
        if [[ "$_line" =~ ^[0-9]+$ ]] && \
            [[ -n $(sudo iptables -L PREROUTING -vt nat --line-numbers | grep "^$_line\ .*") ]]; then
          echo "\r\nSelected line:"
          sudo iptables -L PREROUTING -vt nat --line-numbers | grep "^$_line\ .*"
          read -q "_confirm?Are you sure [yn]? "
          if [[ "$_confirm" =~ ^[Yy]$ ]]; then
            sudo iptables -t nat -D PREROUTING $_line && echo "\r\nDeleted!"
          else
            echo "Aborted!"
          fi
        else
          echo "Invalid line selection"
        fi
        ;;
      input-forward)
        sudo iptables -L FORWARD -v --line-numbers
        echo "\r\n"
        read "_line?What line do you want to delete: "
        if [[ "$_line" =~ ^[0-9]+$ ]] && \
            [[ -n $(sudo iptables -L FORWARD -v --line-numbers | grep "^$_line\ .*") ]]; then
          echo "\r\nSelected line:"
          sudo iptables -L FORWARD -v --line-numbers | grep "^$_line\ .*"
          read -q "_confirm?Are you sure [yn]? "
          if [[ "$_confirm" =~ ^[Yy]$ ]]; then
            sudo iptables -D FORWARD $_line && echo "\r\nDeleted!"
          else
            echo "\r\nAborted!"
          fi
        else
          echo "Invalid line selection"
        fi
        ;;
      *) echo "oops!not implemented!"
        ;;
    esac
  else
    echo "fatal: invalid profile"
  fi
}
compctl -k "($_firewall_delete_profile)" config-firewall-delete

function config-firewall-nat-add() {
  if [[ -n $1 ]] && [[ -n $2 ]] && [[ -n $3 ]]; then
    # backup
    mkdir -p $DOTFILES_DIR/backup/iptables
    sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v4
    sudo ip6tables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v6

    sudo iptables -t nat -D PREROUTING -p tcp --dport "$2" -j DNAT --to-destination "$1":"$3" 2> /dev/null
    sudo iptables -t nat -I PREROUTING -p tcp --dport "$2" -j DNAT --to-destination "$1":"$3"
    sudo iptables -D FORWARD -d "$1" -p tcp -m state --state NEW -m tcp --dport "$3" -j ACCEPT 2> /dev/null
    sudo iptables -I FORWARD -d "$1" -p tcp -m state --state NEW -m tcp --dport "$3" -j ACCEPT

    # backup
    sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.v4
    sudo ip6tables-save >! $DOTFILES_DIR/backup/iptables/rules.v6
  else
    echo "fatal: bad arguments"
    echo "Usage: config-firewall-nat-add new_ip old_port new_port"
  fi
}

function config-firewall-nat-delete() {
  if [[ -n $1 ]] && [[ -n $2 ]] && [[ -n $3 ]]; then
    # backup
    mkdir -p $DOTFILES_DIR/backup/iptables
    sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v4
    sudo ip6tables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v6

    sudo iptables -t nat -D PREROUTING -p tcp --dport "$2" -j DNAT --to-destination "$1":"$3"
    sudo iptables -I FORWARD -d "$1" -p tcp -m state --state NEW -m tcp --dport "$3" -j ACCEPT

    # backup
    sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.v4
    sudo ip6tables-save >! $DOTFILES_DIR/backup/iptables/rules.v6
  else
    echo "fatal: bad arguments"
    echo "Usage: config-firewall-nat-delete new_ip old_port new_port"
  fi
}

_config_profile="firewall firewall-nat"
function config-show() {
  if [[ -n $1 ]] && [[ $_config_profile =~ (^|[[:space:]])$1($|[[:space:]]) ]]; then
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
      firewall-nat)
        echo "NAT CONFIG:\n\r"
        sudo iptables -L PREROUTING -vt nat

        echo "\n\rINPUT CONFIG:\n\r"
        sudo iptables -L FORWARD -v
        ;;
      *) echo "oops!not implemented!"
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
  cp -r $DOTFILES_DIR/backup/* $PRIVATE_FOLDER/backup/backup/$SHORT_HOST/"$_now"
  cd $PRIVATE_FOLDER/backup/backup/$SHORT_HOST/"$_now"
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
  cp -r $DOTFILES_DIR/local/* $PRIVATE_FOLDER/backup/local/$SHORT_HOST/"$_now"
  cd $PRIVATE_FOLDER/backup/local/$SHORT_HOST/"$_now"
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
    *) echo "$1"
      ;;
  esac
}

function guest_clear_cache() {
  sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
}