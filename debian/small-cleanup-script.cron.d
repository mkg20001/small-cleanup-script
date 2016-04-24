#
# Regular cron jobs for the small-cleanup-script package
#
@daily root bash /usr/sbin/small-cleanup-script.sh >> /var/log/small-cleanup-script.log
