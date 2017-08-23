CONDA_HOME=$(conda info | grep root | awk 'BEGIN { FS = " " } ; { print $4 }' | sed 's/^[ \t]*//;s/[ \t]*$//')

_conda_list_envs() {
  compadd $(ls $CONDA_HOME/envs)
}

workon() {
  source activate $1
}
compdef _conda_list_envs workon

workoff() {
  source deactivate
}