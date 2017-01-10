# Aliases
alias reload="echo 'reload help:\n\r\n\rrelzsh: reload zsh\n\rreldotfiles: git pull dotfiles\n\rrecdotfiles: rm and redownload dotfiles\n\rrecsdotfiles: rm and secure redownload dotfiles'"
alias relzsh=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias reldotfiles="git -C "$DOTFILES_DIR" pull; . ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias recdotfiles="rm -rf "$DOTFILES_DIR"; git clone --recursive https://github.com/hungnguyenm/dotfiles "$DOTFILES_DIR"; . ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias recsdotfiles="rm -rf "$DOTFILES_DIR"; git clone --recursive git@github.com:hungnguyenm/dotfiles.git "$DOTFILES_DIR"; . ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"

alias tcc="tmux -CC"
alias tlk="tmux list-keys"

alias emacs="emacs -nw"

alias catc="colorize"

alias rmf="rm -rf"

# Additional alias functions
function xcopy() { xsel --clipboard < "$*"; }
function xover() { xsel --clipboard > "$*"; }
function xpaste() { xsel --clipboard >> "$*"; }

[ -r ~/.ssh/config ] && _ssh_config=($(cat ~/.ssh/config | sed -ne 's/Host[=/t ]\([^\*]\)/\1/p')) || _ssh_config=()
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

function ssh() {
  if (( ${#} == 1 )); then
  	if [[ $_ssh_config =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
  	  command ssh -t "$1" "SSH_CLIENT_SHORT_HOST="$SHORT_HOST" '$SHELL'"
  	else
  	  command ssh "$@"
  	fi
  else
  	command ssh "$@"
  fi
}

compctl -k "($_ssh_config)" fs fsu fsc fso

# Environment
# - update tmux environment variables
if [ -n "$TMUX" ]; then
  function tmux_refresh {
    TMUX_ENV_SSH_AUTH_SOCK=$(tmux show-environment | grep "^SSH_AUTH_SOCK")
    [[ -n "$TMUX_ENV_SSH_AUTH_SOCK" ]] && export "$TMUX_ENV_SSH_AUTH_SOCK"

    TMUX_ENV_DISPLAY=$(tmux show-environment | grep "^DISPLAY")
    [[ -n "$TMUX_ENV_DISPLAY" ]] && export "$TMUX_ENV_DISPLAY"
  }
else
  function tmux_refresh { }
fi

function preexec {
    tmux_refresh
}
