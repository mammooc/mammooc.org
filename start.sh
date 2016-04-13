#!/bin/sh

service cron start
touch /var/spool/cron/crontabs/root
service cron restart
bundle exec rake db:migrate
if [ "$FORCE_SSL" = "true" ]; then
    foreman start -f Procfile-SSL
else
    foreman start
fi
