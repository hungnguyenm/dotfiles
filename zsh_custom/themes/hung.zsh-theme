# features:
# path is autoshortened to ~30 characters

add-zsh-hook chpwd chpwd_update_git_vars
add-zsh-hook preexec preexec_update_git_vars
add-zsh-hook precmd precmd_update_git_vars

function preexec_update_git_vars() {
	case "$2" in
		git*|hub*|gh*|stg*)
		__EXECUTED_GIT_COMMAND=1
		;;
	esac
}

function precmd_update_git_vars() {
	if [ -n "$__EXECUTED_GIT_COMMAND" ] || [ ! -n "$ZSH_THEME_GIT_PROMPT_CACHE" ]; then
		update_current_git_vars
		unset __EXECUTED_GIT_COMMAND
	fi
}

function chpwd_update_git_vars() {
	update_current_git_vars
}

function update_current_git_vars() {
	unset __CURRENT_GIT_STATUS
	local gitstatus="$ZSH_CUSTOM/gitstatus.py"
	_GIT_STATUS=`python3 ${gitstatus} 2>/dev/null`

	__CURRENT_GIT_STATUS=("${(@s: :)_GIT_STATUS}")
		GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
		GIT_AHEAD=$__CURRENT_GIT_STATUS[2]
		GIT_BEHIND=$__CURRENT_GIT_STATUS[3]
		GIT_STAGED=$__CURRENT_GIT_STATUS[4]
		GIT_CONFLICTS=$__CURRENT_GIT_STATUS[5]
		GIT_CHANGED=$__CURRENT_GIT_STATUS[6]
		GIT_UNTRACKED=$__CURRENT_GIT_STATUS[7]
}

function git_prompt() {
	precmd_update_git_vars
	if [ -n "$__CURRENT_GIT_STATUS" ]; then
		STATUS=" ($GIT_BRANCH"
		if [ "$GIT_BEHIND" -ne "0" ]; then
			STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND$GIT_BEHIND%{${reset_color}%}"
		fi
		if [ "$GIT_AHEAD" -ne "0" ]; then
			STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD$GIT_AHEAD%{${reset_color}%}"
		fi
		STATUS="$STATUS|"

		if [ "$GIT_STAGED" -ne "0" ]; then
			STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$GIT_STAGED%{${reset_color}%}"
		fi
		if [ "$GIT_CONFLICTS" -ne "0" ]; then
			STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CONFLICTS$GIT_CONFLICTS%{${reset_color}%}"
		fi
		if [ "$GIT_CHANGED" -ne "0" ]; then
			STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_MODIFIED$GIT_CHANGED%{${reset_color}%}"
		fi
		if [ "$GIT_UNTRACKED" -ne "0" ]; then
			STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED%{${reset_color}%}"
		fi
		if [ "$GIT_CHANGED" -eq "0" ] && [ "$GIT_CONFLICTS" -eq "0" ] && [ "$GIT_STAGED" -eq "0" ] && [ "$GIT_UNTRACKED" -eq "0" ]; then
			STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
		fi

		STATUS="$STATUS%{${reset_color}%}) "
		echo "$STATUS"
	fi
}

# prompt
# - if superuser make the username green
if [ $UID -eq 0 ]; then NCOLOR="green"; else NCOLOR="white"; fi

if [ -n "$SSH_CLIENT" ] && ! [ -n "$TMUX" ]; then
	if [ -n "$SSH_CLIENT_SHORT_HOST" ]; then
		PROMPT='[%{$fg[$NCOLOR]%}%{$SSH_CLIENT_SHORT_HOST%${#SSH_CLIENT_SHORT_HOST}G%}%{$fg[blue]%}%B@%{$PROMPT_HOST_NAME%${#PROMPT_HOST_NAME}G%}%b%{$reset_color%}:%{$fg[red]%}%25<...<%~%<<%{$reset_color%}]$(git_prompt)%{$reset_color%}%(!.#.$) '
	else
		PROMPT='[%{$fg[blue]%}%B%{$PROMPT_HOST_NAME%${#PROMPT_HOST_NAME}G%}%b%{$reset_color%}:%{$fg[red]%}%25<...<%~%<<%{$reset_color%}]$(git_prompt)%{$reset_color%}%(!.#.$) '
	fi
else
	PROMPT='[%{$fg[red]%}%25<...<%~%<<%{$reset_color%}]$(git_prompt)%{$reset_color%}%(!.#.$) '
fi

# Format for parse_git_dirty()
ZSH_THEME_GIT_PROMPT_DIRTY=" "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}v"

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[cyan]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[yellow]%}?"

# Additional format
ZSH_THEME_GIT_PROMPT_BEHIND="%{↓%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%G%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}%{^%G%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg_bold[red]%}%{x%G%}"

# LS colors, made with http://geoff.greer.fm/lscolors/
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS='no=00:fi=00:di=01;34:ln=00;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=41;33;01:ex=00;32:*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32:*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31:*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35:*.dl=01;35:*.gl=01;35:*.wmv=01;35:*.aiff=00;32:*.au=00;32:*.mid=00;32:*.mp3=00;32:*.ogg=00;32:*.voc=00;32:*.wav=00;32:'
