#!/bin/bash

service cron start
touch /var/spool/cron/crontabs/root
service cron restart
bundle exec rake db:migrate
foreman start
