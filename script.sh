#!/bin/bash

red=$(tput setaf 1)
reset=$(tput sgr0)
logfile="/var/log/small-cleanup-script.log"

set -e

log() {
echo "$red[CLEAN] $(date) $@$reset"
}
logit() {
  logger "[$$] [small-cleanup-script] $*"
}

if [ "$USER" != "root" ]; then
  groups $USER | grep "sudo" -o > /dev/null 2> /dev/null
  if [ $? -ne 0 ] && [ "x$1" != "x-f" ]; then
    log "You have no permission to run this command!"
    log "This was reported"
    log "If you think this is an error try -f"
    arg=""
    if ! [ -z "$1" ]; then
      arg=" (arguments: $*)"
    fi
    logit "User $USER had no permission to run this script!$arg"
    exit 2
  fi
  if ! [ -z "$1" ]; then
    logit "Executed by user $USER with arguments $*"
    s="sudo bash $(readlink -f $0) $*"
  else
    logit "Executed by user $USER"
    s="sudo bash $(readlink -f $0)"
  fi
  log "Executing $s..."
  sudo $s
  exit $?
fi

logit "Running script with arguments $*"

if [ "x$1" = "xcron" ]; then
  if ! [ -e "$logfile" ]; then
    touch $logfile
    chmod 755 $logfile
    chown root:root $logfile
  fi
  log "Logging to $logfile"
  tail -f $logfile -n 0 --pid=$$ &
  logit "Running as cronjob"
  #Set PATH for cronjob
  PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
  #Execute as cronjob
  bash $(readlink -f $0) &>> $logfile
  logit "Cronjob finished"
  exit $?
fi

#Update and Clean
log "APT-GET UPDATE"
apt-get update > /dev/null
log "APT-GET DIST-UPGRADE -Y"
apt-get dist-upgrade -y
log "APT-GET AUTOREMOVE -Y"
apt-get autoremove -y
log "APT-GET CLEAN"
apt-get clean

#Purge old Stuff
rclist=`echo $(dpkg -l | awk '$1 == "rc" { print $2; }')`
for f in $rclist; do
  logit "Purged $f"
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
  snap refresh
fi

log "DONE"
