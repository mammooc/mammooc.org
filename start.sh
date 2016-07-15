#!/bin/sh

# Prepare assets
bundle exec rake assets:precompile

# Save environment variables to disk
printenv | sed 's/^\(.*\)$/export \1/g' > $APP_HOME/export_env.sh

# Start cron scheduler
service cron start
touch /var/spool/cron/crontabs/root
service cron restart

# Migrate database
bundle exec rake db:migrate

# Start services
if [ "$FORCE_SSL" = "true" ]; then
    foreman start -f Procfile-SSL
else
    foreman start
fi
