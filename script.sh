#!/bin/sh

log() {
echo "$(tput setaf 1)[CLEAN] $(date) $@$(tput sgr0)"
}
logit() {
  logger "[small-cleanup-script] $*"
}

if [ $USER != "root" ]; then
  groups $USER | grep "sudo" -o > /dev/null 2> /dev/null
  if [ $? -ne 0 ] && [ "x$1" != "x-f" ]; then
    log "You have no permission to run this command!"
    log "This was reported"
    log "If you think this is an error try -f"
    logit "User $USER had no permission to run this script! (arguments: $*)"
    exit 2
  fi
  logit "Executed from user $USER with arguments $*"
  s="sudo bash `realpath $0` $*"
  log "Run as root via sudo... ($s)"
  sudo $s
  exit $?
fi

logit "Running script with arguments $*"

if [ "x$1" = "xcron" ]; then
  log "Logging to /var/log/small-cleanup-script.log"
  logit "Running as cronjob"
  #Set PATH for cronjob
  PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
  #Execute as cronjob
  bash `realpath $0` &>> /var/log/small-cleanup-script.log
  exit $?
fi

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
  snap list | awk -F" " '{if ($1 && NR>1) { system("snap refresh " $1 " 2> /dev/null") }}'
fi

log "DONE"
