# clipboard
function xcopy() { xsel --clipboard < "$*"; }
function xover() { xsel --clipboard > "$*"; }
function xpaste() { xsel --clipboard >> "$*"; }

# fail-safe sudo commands
function shutdown() {
  read -q "_confirm?Do you want to shutdown $HOST [yn]? "
  echo "\r\n"
  if [[ "$_confirm" =~ ^[Yy]$ ]]; then
    sudo shutdown now
  fi
}

function reboot() {
  read -q "_confirm?Do you want to reboot $HOST [yn]? "
  echo "\r\n"
  if [[ "$_confirm" =~ ^[Yy]$ ]]; then
    sudo reboot
  fi
}

# backup to private repository
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