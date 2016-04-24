#
# Regular cron jobs for the small-cleanup-script package
#
@daily root bash /usr/sbin/small-cleanup-script.sh 2>&1 >> /var/log/small-cleanup-script.log
