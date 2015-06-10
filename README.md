[![Continuous Integration: Circle CI](https://circleci.com/gh/jprberlin/mammooc.svg?style=shield&circle-token=60a6a79493a571b2253594c37e9d92e0f9517298)](https://circleci.com/gh/jprberlin/mammooc)
[![Dependency Status: Gemnasium](https://gemnasium.com/84d7945008fa3b98c265c0ba5cc37fa4.svg)](https://gemnasium.com/jprberlin/mammooc)

## mammooc
_Please pay attention to the LICENSE file as well_

mammooc is a student's project developed at the German Hasso Plattner Institute, Potsdam.

# Setup

## Docker:
```
docker-compose run
docker-compose run web rake db:create db:setup
docker-compose run web rake assets:precompile
```

## Environment variables

These environment variables are for use in Production mode:

| Usage              | Environment variable      |
|--------------------|---------------------------|
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

----------------------------------------------------------------

It might be useful to set the following one in Development mode:

| Usage                  | Environment variable  | Value      |
|------------------------|-----------------------|------------|
| Use PhantomJS          | `PHANTOM_JS`          | `true`     |
| Start Redis & Sidekiq  | `AUTO_START_SIDEKIQ`  | `true`     |
| Use SSL                | `FORCE_SSL`           | `true`     |
| Seed-Token for openHPI | `OPEN_HPI_TOKEN`      | individual |
| Seed-Token for openSAP | `OPEN_SAP_TOKEN`      | individual |
