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
