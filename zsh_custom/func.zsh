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
             mark = percent / 10 * 2
             printf "%3d%% [", percent
             for (i=0;i<=mark;i++)
                printf "="
             printf ">"
             for (i=mark;i<20;i++)
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
             mark = percent / 10 * 2
             printf "%3d%% [", percent
             for (i=0;i<=mark;i++)
                printf "="
             printf ">"
             for (i=mark;i<20;i++)
                printf " "
             printf "]\r"
          }
        }
        END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}

# send email notify after a command finishes
function enotify() {
  if [ -n "$NOTIFY_USER" ] && [ -n "$NOTIFY_PASS" ] && [ -n "$NOTIFY_RCPT" ]; then
    if [ -n "$PREFER_HOST_NAME" ]; then
      name=$PREFER_HOST_NAME
    else
      name=$(hostname)
    fi

    { output=$((time $@)|tee /dev/fd/5); } 5>&1

    if [ $? -eq 0 ]; then
      msg="Command \"$@\" finished!"
    else
      msg="Command \"$@\" failed!"
    fi
    from="From:$name <$NOTIFY_USER>\n"
    to="To:$NOTIFY_RCPT\n"
    subject="Subject:[$name] $msg\n"
    prefix="MIME-Version: 1.0\nContent-Type: text/html\nContent-Disposition: inline\n<html>\n<body>\n<pre style=\"font: monospace\">\n"
    suffix="</pre></body></html>"
    msg="$msg\n\n=== Output ===\n$output"

    curl --ssl-reqd --silent --output /dev/null --connect-timeout 15 \
      --url "smtps://smtp.gmail.com:465" \
      --mail-from "$NOTIFY_USER" \
      --mail-rcpt "$NOTIFY_RCPT" \
      --user "$NOTIFY_USER:$NOTIFY_PASS" \
      --upload-file =(echo "$from$to$subject$prefix$msg$suffix")

    if [ $? -eq 0 ]; then
      echo "  Notification email sent!"
    else
      echo "  Failed to send notification email"
    fi

  else
    echo "fatal: login information is not set"
  fi
}