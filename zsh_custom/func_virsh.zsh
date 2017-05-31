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
          sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
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