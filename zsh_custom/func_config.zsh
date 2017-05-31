function config-test() {
  git_clone_private
  $PRIVATE_FOLDER/echo.sh
  git_remove_private
}

_ssh_profile="ubuntu-desktop ubuntu-server debian-embedded debian-embedded-defaultssh"
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

            # update persistent
            sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
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

            # update persistent
            sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
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

    # update persistent
    sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
    sudo sh -c 'ip6tables-save > /etc/iptables/rules.v6'
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

    # update persistent
    sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
    sudo sh -c 'ip6tables-save > /etc/iptables/rules.v6'
  else
    echo "fatal: bad arguments"
    echo "Usage: config-firewall-nat-delete new_ip old_port new_port"
  fi
}

function config-firewall-reset() {
  read -q "_confirm?Are you sure [yn]? "
  if [[ "$_confirm" =~ ^[Yy]$ ]]; then
    # backup
    mkdir -p $DOTFILES_DIR/backup/iptables
    sudo iptables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v4
    sudo ip6tables-save >! $DOTFILES_DIR/backup/iptables/rules.old.v6

    # reset IPv4
    sudo iptables -P INPUT ACCEPT
    sudo iptables -P FORWARD ACCEPT
    sudo iptables -P OUTPUT ACCEPT
    sudo iptables -t nat -F
    sudo iptables -t mangle -F
    sudo iptables -F
    sudo iptables -X

    # reset IPv6
    sudo ip6tables -P INPUT ACCEPT
    sudo ip6tables -P FORWARD ACCEPT
    sudo ip6tables -P OUTPUT ACCEPT
    sudo ip6tables -t nat -F
    sudo ip6tables -t mangle -F
    sudo ip6tables -F
    sudo ip6tables -X

    # update persistent
    sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
    sudo sh -c 'ip6tables-save > /etc/iptables/rules.v6'

    echo "\r\nDone!"
  else
    echo "\r\nAborted!"
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