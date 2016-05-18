#
# Regular cron jobs for the small-cleanup-script package
#
@daily root bash /usr/bin/small-cleanup-script 2>&1 >> /var/log/small-cleanup-script.log
