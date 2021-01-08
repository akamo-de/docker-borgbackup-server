#!/bin/sh

if [ ! -d /backup/destination/ssh ]
then
  mkdir /backup/destination/ssh
  ## create host key
  ssh-keygen -t ed25519 -a 100 -N "" -f /backup/destination/ssh/ssh_host_ed25519
  chown backup:root /backup/destination/ssh/ssh_host_ed25519
  ## crate user key
  if [ -z "$SYSTEM_NAME" ]
  then
    export SYSTEM_NAME="akamo-backup-server"
  fi
  ssh-keygen -o -a 100 -t ed25519 -N ""  -f /backup/destination/ssh/id_backup -C "backup@$SYSTEM_NAME"
fi

if [ ! -f /backup/destination/backup_id_enc ]
then
  cat /backup/destination/ssh/id_backup |gzip -9| base64 | awk '{printf("%s", $0)}' > /backup/destination/backup_id_enc
fi

if [ ! -d /backup/destination/backup ]
then
  # generate password of no password provided
  if [ -z "$BORG_PASSPHRASE" ]
  then
    export BORG_PASSPHRASE="$(LC_ALL=C tr -dc '[:alnum:]' < /dev/urandom | head -c20)"
    echo "$BORG_PASSPHRASE" > /backup/destination/borg_pwd
    chown root:root /backup/destination/borg_pwd
    chmod 400 /backup/destination/borg_pwd
  fi
  mkdir /backup/destination/backup
  chown backup:root /backup/destination/backup
  su -l - backup -c "BORG_PASSPHRASE=\"$BORG_PASSPHRASE\" /usr/bin/borg init --encryption=repokey-blake2 /backup/destination/backup"
  su -l - backup -c "/usr/bin/borg key export /backup/destination/backup /tmp/borg_key"
  chown root:root /tmp/borg_key
  chmod 400 /tmp/borg_key
  mv /tmp/borg_key /backup/destination/borg_key
fi

## create authorized key file
SSH_PUBKEY="$(head -n1 /backup/destination/ssh/id_backup.pub)"
if [ -z "$BORG_QUOTA" ]
then
  echo "command=\"/usr/bin/borg serve --restrict-to-repository /backup/destination/backup\",restrict $SSH_PUBKEY" > /etc/authorized_key_backup
else
  echo "command=\"/usr/bin/borg serve --storage-quota $BORG_QUOTA --restrict-to-repository /backup/destination/backup\",restrict $SSH_PUBKEY" > /etc/authorized_key_backup
fi
chown backup:root /etc/authorized_key_backup
chmod 400 /etc/authorized_key_backup

## prepare sshd
mkdir -p /run/sshd
chown backup:root /run/sshd


## start supervisor
/usr/bin/supervisord -c /etc/supervisord.conf
