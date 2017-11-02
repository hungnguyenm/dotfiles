# sudo preserve LD_LIBRARY_PATH
alias sudo="sudo env LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

# dotfiles
alias reload="echo 'rls: reload shell\n\rrlz: reload zsh\n\rrldot: git pull dotfiles\n\rrlcomp: rebuild compdump\n\rrcdot: rm and redownload dotfiles\n\rrcsdot: rm and secure redownload dotfiles'"
alias rls="exec $SHELL -l"
alias rlz=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias rldot="git -C "$DOTFILES_DIR" pull; . ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias rlcomp="rehash"
alias rcdot="rm -rf "$DOTFILES_DIR"; git clone --recursive https://github.com/hungnguyenm/dotfiles "$DOTFILES_DIR"; . ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias rcsdot="rm -rf "$DOTFILES_DIR"; git clone --recursive git@github.com:hungnguyenm/dotfiles.git "$DOTFILES_DIR"; . ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"

# short commands
alias agrep="alias | grep"

alias cls="clear"

alias gsui="git submodule update --init --recursive --remote"
alias grc1="git reset --soft HEAD^;git push origin +master"

alias tcc="tmux -CC"
alias tlk="tmux list-keys"

alias emacs="emacs -nw"

alias rmf="rm -rf"
alias rmcrash="sudo rm /var/crash/*"

# network
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias restart_network="sudo ifdown --exclude=lo -a && sudo ifup --exclude=lo -a"

# utility
alias dus="du -sh"
alias dfd="df . -h"
alias dfh="df -h"
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'
alias catc="colorize"
alias path='echo -e ${PATH//:/\\n}'
alias zsh_debug="/bin/zsh -i -x -c exit; set +xv;"
alias w_nvidiasmi="watch -n 0.5 nvidia-smi"

# virtualbox
alias vbm="VBoxManage"
alias vbh="VBoxHeadless"
alias vbg="VirtualBox"

# sound
alias sound_loop_on="pactl load-module module-loopback latency_msec=1"
alias sound_loop_off="pactl unload-module module-loopback"

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