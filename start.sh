#!/bin/bash

service cron start
bundle exec rake db:migrate
foreman start
