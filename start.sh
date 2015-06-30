#!/bin/bash

service start cron
bundle exec rake db:migrate
foreman start
