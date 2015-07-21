# mammooc

[![Continuous Integration: Circle CI](https://circleci.com/gh/mammooc/mammooc.org.svg?style=shield)](https://circleci.com/gh/mammooc/mammooc.org) 
[![Code Climate](https://codeclimate.com/github/mammooc/mammooc.org/badges/gpa.svg)](https://codeclimate.com/github/mammooc/mammooc.org)
[![Coverage Status](https://coveralls.io/repos/mammooc/mammooc.org/badge.svg?branch=master&service=github)](https://coveralls.io/github/mammooc/mammooc.org?branch=master)
[![Dependency Status: Gemnasium](https://gemnasium.com/mammooc/mammooc.org.svg)](https://gemnasium.com/mammooc/mammooc.org)
[![Stories in progress: Waffle.io](https://badge.waffle.io/mammooc/mammooc.org.png?label=In%20Progress&title=In%20Progress)](https://waffle.io/mammooc/mammooc.org)
[![PullReview stats](https://www.pullreview.com/github/mammooc/mammooc.org/badges/master.svg?)](https://www.pullreview.com/github/mammooc/mammooc.org/reviews/master)

_Please pay attention to the LICENSE file as well_

mammooc is a student's project developed at the German Hasso Plattner Institute, Potsdam.

# Setup

## Docker:

We use this docker image for deployment: https://registry.hub.docker.com/u/jprberlin/mammooc/

You have to modify the `docker-compose.yml` and include your own environment variables. Run the following commands from the same working directory in order to set up your instance of mammooc:

```
docker-compose pull jprberlin/mammooc
docker-compose run web rake db:create db:setup
docker-compose up
```

### Run as a service:

Just create a new service file located in `/etc/init/mammooc.conf` with the following content:

```
description "mammooc init script"

respawn
respawn limit 10 5
umask 022

chdir <mammooc working directory>

setuid <user name>
setgid <group name>

exec docker-compose up
```

Control this service using `service mammooc [start|stop|restart]`.

### Update your mammooc installation:

```
#!/bin/bash

docker pull jprberlin/mammooc
service mammooc restart
```

### Connect to the docker image:

`docker exec -it <docker container ID> bash`

## SSL

You can use an additional nginx to seucre connections or you may enable SSL in Passenger. Just add the following command line arguments to the Procfile and place a SSL certificate inside the docker image within the folder `ssl`. Pay attention if you update the image! 

```
--ssl --ssl-certificate ./ssl/mammooc.pem --ssl-certificate-key ./ssl/mammooc.key
```


## Environment variables

These environment variables are for use in Production mode:

| Usage              | Environment variable      |
|--------------------|---------------------------|
| Domain Name        | `DOMAIN`                  |
| Amazon S3          | `AWS_ACCESS_KEY_ID`       |
|                    | `AWS_SECRET_ACCESS_KEY`   |
|                    | `AWS_REGION`              |
|                    | `S3_BUCKET_NAME`          |
| Coursera User Data | `COURSERA_CLIENT_ID`      |
|                    | `COURSERA_SECRET_KEY`     |
| Facebook Login     | `FACEBOOK_CLIENT_ID`      |
|                    | `FACEBOOK_SECRET_KEY`     |
| Google Login       | `GOOGLE_CLIENT_ID`        |
|                    | `GOOGLE_SECRET_KEY`       |
| GitHub Login       | `GITHUB_CLIENT_ID`        |
|                    | `GITHUB_SECRET_KEY`       |
| LinkedIn Login     | `LINKEDIN_CLIENT_ID`      |
|                    | `LINKEDIN_SECRET_KEY`     |
| Twitter Login      | `TWITTER_CLIENT_ID`       |
|                    | `TWITTER_SECRECT_KEY`     |
| Windows Live Login | `WINDOWS_LIVE_CLIENT_ID`  |
|                    | `WINDOWS_LIVE_SECRET_KEY` |
| Amazon Login       | `AMAZON_CLIENT_ID`        |
|                    | `AMAZON_SECRET_KEY`       |
| New Relic          | `NEW_RELIC_LICENSE_KEY`   |
| SMTP with Mandrill | `MANDRILL_USERNAME`       |
|                    | `MANDRILL_APIKEY`         |

----------------------------------------------------------------

It might be useful to set the following one in Development mode:

| Usage                  | Environment variable  | Value      |
|------------------------|-----------------------|------------|
| Use PhantomJS          | `PHANTOM_JS`          | `true`     |
| Start Redis & Sidekiq  | `AUTO_START_SIDEKIQ`  | `true`     |
| Use SSL                | `FORCE_SSL`           | `true`     |
| Seed-Token for openHPI | `OPEN_HPI_TOKEN`      | individual |
| Seed-Token for openSAP | `OPEN_SAP_TOKEN`      | individual |
