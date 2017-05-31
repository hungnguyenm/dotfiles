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
  	  command ssh -t "$1" "if type $SHELL >/dev/null 2>&1; then SSH_CLIENT_SHORT_HOST="${PREFER_HOST_NAME:-${SHORT_HOST}}" $SHELL; elif type zsh >/dev/null 2>&1; then SSH_CLIENT_SHORT_HOST="${PREFER_HOST_NAME:-${SHORT_HOST}}" zsh; else bash; fi;"
  	else
  	  command ssh "$@"
  	fi
  else
  	command ssh "$@"
  fi
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