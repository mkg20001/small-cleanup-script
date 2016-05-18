#
# Regular cron jobs for the small-cleanup-script package
#
@daily root /usr/bin/small-cleanup-script &>> /var/log/small-cleanup-script.log
