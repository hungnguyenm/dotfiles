# based on mh theme

# features:
# path is autoshortened to ~30 characters
# turns username green if superuser, otherwise it is white

# if superuser make the username green
if [ $UID -eq 0 ]; then NCOLOR="green"; else NCOLOR="white"; fi

function git_prompt() {
  local ref
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$(parse_git_dirty)"
  fi
}

# prompt
if [ -n "$SSH_CLIENT" ]; then
	PROMPT='[%{$fg[$NCOLOR]%}%B%n%{$fg[blue]%}@%m%b%{$reset_color%}:%{$fg[red]%}%25<...<%~%<<%{$reset_color%}]$(git_prompt)$(git_prompt_status)%{$reset_color%}%(!.#.$) '
else
	PROMPT='[%{$fg[$NCOLOR]%}%B%n%b%{$reset_color%}:%{$fg[red]%}%25<...<%~%<<%{$reset_color%}]$(git_prompt)$(git_prompt_status)%{$reset_color%}%(!.#.$) '
fi

# Format for parse_git_dirty()
ZSH_THEME_GIT_PROMPT_DIRTY=" "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%} v"

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}?"

# LS colors, made with http://geoff.greer.fm/lscolors/
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS='no=00:fi=00:di=01;34:ln=00;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=41;33;01:ex=00;32:*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32:*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31:*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35:*.dl=01;35:*.gl=01;35:*.wmv=01;35:*.aiff=00;32:*.au=00;32:*.mid=00;32:*.mp3=00;32:*.ogg=00;32:*.voc=00;32:*.wav=00;32:'
