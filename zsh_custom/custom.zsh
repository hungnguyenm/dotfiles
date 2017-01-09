# Aliases
alias reload="echo 'reload help:\n\r\n\rrelzsh: reload zsh\n\rreldotfiles: git pull dotfiles\n\rrecdotfiles: rm and redownload dotfiles'"
alias relzsh=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias reldotfiles="git -C "$DOTFILES_DIR" pull"
alias recdotfiles="rm -rf "$DOTFILES_DIR"; git clone --recursive https://github.com/hungnguyenm/dotfiles "$DOTFILES_DIR""
alias recsdotfiles="rm -rf "$DOTFILES_DIR"; git clone --recursive git@github.com:hungnguyenm/dotfiles.git "$DOTFILES_DIR""

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

compctl -k "($_ssh_config)" fs fsu fsc

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
