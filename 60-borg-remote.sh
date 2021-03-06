#!/bin/sh
# borg backupninja backup script
REPOSITORY=
export BORG_PASSPHRASE=''
# On rsync.net: Specify /usr/local/bin/borg/borg for borg 0.29; /usr/local/bin/borg1 for 1.0.9
REMOTE_PATH=/usr/local/bin/borg1/borg1

info "Starting borg backup"

# Run the backup.
OUTPUT=$( (
borg create --verbose --stats --compression lz4         \
--remote-path $REMOTE_PATH \
$REPOSITORY::'{hostname}-{now:%Y-%m-%d}' \
/etc \
/var/spool/cron \
/var/backups \
/var/www \
/var/log \
/root \
/home \
/usr/local/bin \
/usr/local/sbin \
/var/lib/dpkg/status \
/var/lib/dpkg/status-old \
--exclude '/home/*/.steam/steam/steamapps/common/' \
--exclude '/home/*/.cache' \
--exclude '/home/*/.mozilla/firefox/*/Cache'
) 2>&1)
if [ $? -ne 0 ]
  then
  warning $OUTPUT
fi
info $OUTPUT

# Remove old backups.
OUTPUT=$( (
borg prune -v $REPOSITORY --prefix '{hostname}-' --keep-daily=15 --keep-weekly=9 --keep-monthly=6 --remote-path $REMOTE_PATH
) 2>&1)
if [ $? -ne 0 ]
  then
  warning $OUTPUT
fi
info $OUTPUT

# Check the integrity of the backup.
OUTPUT=$( (
borg check $REPOSITORY --remote-path $REMOTE_PATH
) 2>&1)
if [ $? -ne 0 ]
  then
  warning $OUTPUT
fi
info $OUTPUT
unset BORG_PASSPHRASE
