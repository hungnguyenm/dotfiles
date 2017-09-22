function git_clone_private() {
  mkdir -p $PRIVATE_FOLDER
  rm -rf $PRIVATE_FOLDER
  git clone $PRIVATE_GIT $PRIVATE_FOLDER
}

function git_remove_private() {
  rm -rf $PRIVATE_FOLDER
}

function iptables_dpt_map() {
  case "$1" in
    22) echo "ssh"
      ;;
    69) echo "tftp"
      ;;
    80) echo "http"
      ;;
    443) echo "https"
      ;;
    *) echo "$1"
      ;;
  esac
}

function guest_clear_cache() {
  sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
}

# cp with progress
function pcp() {
  strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
    | awk '{
      count += $NF
          if (count % 10 == 0) {
             percent = count / total_size * 100
             printf "%3d%% [", percent
             for (i=0;i<=percent;i++)
                printf "="
             printf ">"
             for (i=percent;i<10;i++)
                printf " "
             printf "]\r"
          }
        }
        END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}

# mv with progress
function pmv() {
  strace -q -ewrite mv -- "${1}" "${2}" 2>&1 \
    | awk '{
      count += $NF
          if (count % 10 == 0) {
             percent = count / total_size * 100
             printf "%3d%% [", percent
             for (i=0;i<=percent;i++)
                printf "="
             printf ">"
             for (i=percent;i<10;i++)
                printf " "
             printf "]\r"
          }
        }
        END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}