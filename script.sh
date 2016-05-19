#!/bin/sh

log() {
echo "$(tput setaf 1)[CLEAN] $(date) $@$(tput sgr0)"
}

if [ $USER != "root" ]; then
  log "Login as root via sudo... (sudo $0)"
  sudo $0
  exit 0
fi

#Set PATH for cronjob
PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

#Update and Clean
log "APT-GET UPDATE"
apt-get update > /dev/null
log "APT-GET DISTUPGRADE -Y"
apt-get dist-upgrade -y
log "APT-GET AUTOREMOVE -Y"
apt-get autoremove -y
log "APT-GET CLEAN"
apt-get clean

#Purge old Stuff
rclist=`echo $(dpkg -l | awk '$1 == "rc" { print $2; }')`
for f in $rclist; do
  log "PURGE" $f
done
if [ "$rclist" ]; then
  apt-get remove --purge $rclist -y
else
  log "Nothing to PURGE"
fi

#Snappy Stuff
if [ -f "/usr/bin/snap"  ]; then
  log "SNAP REFRESH"
  snap list | awk -F" " '{if ($1 && NR>1) { system("snap refresh " $1 " 2> /dev/null") }}'
fi

log "DONE"
