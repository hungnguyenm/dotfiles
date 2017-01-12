# dotfiles
alias reload="echo 'rls: reload shell\n\rrlz: reload zsh\n\rrldot: git pull dotfiles\n\rrlcomp: rebuild compdump\n\rrcdot: rm and redownload dotfiles\n\rrcsdot: rm and secure redownload dotfiles'"
alias rls="exec $SHELL -l"
alias rlz=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias rldot="git -C "$DOTFILES_DIR" pull; . ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias rlcomp="rehash"
alias rcdot="rm -rf "$DOTFILES_DIR"; git clone --recursive https://github.com/hungnguyenm/dotfiles "$DOTFILES_DIR"; . ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias rcsdot="rm -rf "$DOTFILES_DIR"; git clone --recursive git@github.com:hungnguyenm/dotfiles.git "$DOTFILES_DIR"; . ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"

# short commands
alias cls="clear"

alias gsui="git submodule update --init --recursive --remote"

alias tcc="tmux -CC"
alias tlk="tmux list-keys"

alias emacs="emacs -nw"

alias rmf="rm -rf"

# network
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

# utility
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'
alias catc="colorize"
alias path='echo -e ${PATH//:/\\n}'
alias zsh_debug="/bin/zsh -i -x -c exit; set +xv;"

# virtualbox
alias vbm="VBoxManage"
alias vbh="VBoxHeadless"
alias vbg="VirtualBox"

# macOS aliases
alias clean_dsfile="find . -type f -name '*.DS_Store' -ls -delete"

# - Merge PDF files
#    Usage: `mergepdf -o output.pdf input{1,2,3}.pdf`
alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'

# - Ring the terminal bell, and put a badge on Terminal.app’s Dock icon
#    (useful when executing time-consuming commands)
alias badge="tput bel"

# - Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"