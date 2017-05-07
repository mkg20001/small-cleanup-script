#
# Regular cron jobs for the small-cleanup-script package
#
@daily root /usr/bin/small-cleanup-script cron >> /var/log/small-cleanup-script.log 2>> /var/log/small-cleanup-script.log
