if [ "$DEBUG_SSH" == "true" ]; then
  : ${DEBUG_SSH_PORT:=22}
  : ${DEBUG_SSH_DESTPORT:=43022}
  echo -e "$(base64 -d <<<"$DEBUG_SSH_KEY")" >/tmp/key
  chmod 600 /tmp/key
  password="$(date +%s | sha256sum | base64 | head -c 32)"
  adduser --disabled-password debug
  echo "debug:$password" | chpasswd
  ssh-keyscan -p $DEBUG_SSH_PORT -H $DEBUG_SSH_DOMAIN > ~/.ssh/known_hosts
  apt update -y && apt install ssh tmux -y
  /etc/init.d/ssh start
  rpassword="$(date +%s | sha256sum | base64 | head -c 32)"
  echo "root:$rpassword" | chpasswd
  echo "1" >/tmp/ssh_timeout
  echo -e "$password\n$rpassword" >/tmp/pwd
  scp -P $DEBUG_SSH_PORT -i /tmp/key /tmp/pwd $DEBUG_SSH_USERNAME@$DEBUG_SSH_DOMAIN:/tmp/docker_password
  rm /tmp/pwd
  nohup ssh -f -N -R $DEBUG_SSH_DESTPORT:localhost:22 -p $DEBUG_SSH_PORT -i /tmp/key $DEBUG_SSH_USERNAME@$DEBUG_SSH_DOMAIN &
  (
    sleep ${DEBUG_SSH_TIMEOUT:-1} && sleep $(cat /tmp/ssh_timeout) && /etc/init.d/ssh stop
  ) &
fi
