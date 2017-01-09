# Aliases
alias reload="echo 'reload help:\n\r\n\rrelzsh: reload zsh\n\rreldotfiles: git pull dotfiles\n\rrecdotfiles: rm and redownload dotfiles'"
alias relzsh=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias recdotfiles="rm -rf ~/dotfiles; git clone --recursive https://github.com/hungnguyenm/dotfiles"
alias reldotfiles="git -C ~/dotfiles pull"

alias tcc="tmux -CC"
alias tlk="tmux list-keys"

alias emacs="emacs -nw"

# Additional alias functions
function xcopy() { xsel --clipboard < "$*"; }
function xover() { xsel --clipboard > "$*"; }
function xpaste() { xsel --clipboard >> "$*"; }

function fs() {
  if [[ -n "$1" ]] ; then
    mkdir -p ~/remote/"$1"
    if [[ -n "$2" ]] ; then
      sshfs "$1":"$2" ~/remote/"$1"
    else
      sshfs "$1": ~/remote/"$1"
    fi
  else
    echo "fatal: fs only works with hosts defined in ~/.ssh/config\n\rUsage: fs host OR fs host path"
  fi
}

function fsu() {
  if [[ -n "$1" ]] ; then
    case `uname` in
      Darwin) umount ~/remote/"$1"
        ;;
      Linux) fusermount -u ~/remote/"$1"
        ;;
    esac
  else
    echo "fatal: fsu only works with hosts defined in ~/.ssh/config"
  fi
}

compdef _hosts fs
compdef _hosts fsu

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