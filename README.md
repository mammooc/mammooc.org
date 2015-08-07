# mammooc

[![Continuous Integration: Circle CI](https://circleci.com/gh/mammooc/mammooc.org.svg?style=shield)](https://circleci.com/gh/mammooc/mammooc.org) 
[![Code Climate](https://codeclimate.com/github/mammooc/mammooc.org/badges/gpa.svg)](https://codeclimate.com/github/mammooc/mammooc.org)
[![Coverage Status](https://coveralls.io/repos/mammooc/mammooc.org/badge.svg?branch=master&service=github)](https://coveralls.io/github/mammooc/mammooc.org?branch=master)
[![Dependency Status: Gemnasium](https://gemnasium.com/mammooc/mammooc.org.svg)](https://gemnasium.com/mammooc/mammooc.org)
[![Stories in progress: Waffle.io](https://badge.waffle.io/mammooc/mammooc.org.png?label=In%20Progress&title=In%20Progress)](https://waffle.io/mammooc/mammooc.org)
[![PullReview stats](https://www.pullreview.com/github/mammooc/mammooc.org/badges/master.svg?)](https://www.pullreview.com/github/mammooc/mammooc.org/reviews/master)

_Please pay attention to the LICENSE file as well_

mammooc is a student's project developed at the German Hasso Plattner Institute, Potsdam.

## How To Contribute
We are happy about everyone who contributes to mammooc!
Here is a little guide to simplify contributing: 

1. Fork the Repository 
2. Implement a new feature or fix a bug (have a look at our [Issues](https://github.com/mammooc/mammooc.org/issues))
3. Add tests for your code
 - we use rspec for model and controller tests
 - for our feature tests we use capybara (with selenium)
 - You can find all tests in the spec directory
 - To run all tests: ```bundle exec rspec```
4. Create Pull request
 - if your request gets two times a +1, we will merge your request 

If you want to do a perfect job:
- have a look at our [Code Style Guideline](Code Style Guidelines)
- we use rubocop to automatically correct the code: ```rake rubocop:run``` 

How you run the application on localhost:

1. please have a look at our environment variables below
 - some of them are marked as necessary, these have to be set for running the application
2. we use passenger as application server
 - to start the application: ```passenger start```
 - the application is available at: ```localhost:3000``` 
 - stop the application: ```passenger stop```

If you want to test out stuff feel free to use our dev deployment (so you don't polute the production data):
- Our dev-branch is deployed under: https://mammooc-dev.herokuapp.com/
- Username: ```max@example.com``` or ```maxi@example.com```
- Password: ```12345678```
- the database will be reset after each deployment  

For any questions:

1. open a new issue
2. add the label 'question'
3. Write down your question
4. we will answer as soon as possible :)


## How to report a bug
1. open a new issue
2. add label 'bug'
3. describe the problem in a way that we can reconstruct what you have done
4. add information about the browser you are using


## Environment variables

It might be useful to set the following one in Development mode:

| Usage                  | Environment variable  | Value      | Necessary | Description |
|------------------------|-----------------------|------------|-----------|-------------|
| Amazon S3              | `WITH_S3`             | `false`    |  ✓        | Enable usage of Amazon S3 Server |
| Start Redis & Sidekiq  | `AUTO_START_SIDEKIQ`  | `true`     |  ✓        | Enable starting of Redis and Sidekiq server within passenger |
| Use PhantomJS          | `PHANTOM_JS`          | `true`     |           | Enable usage of PhantomJS instead of Selenium for running Capybara tests; for further information: [Wiki/PhantomJS](https://github.com/mammooc/mammooc.org/wiki/Headless-Selenium-Tests---PhantomJS)  |
| Use SSL                | `FORCE_SSL`           | `true`     |           | Enable SSL, needed for single-sign-on; you will need a SSL-certificate, for further information: [Wiki/Enable SSL](https://github.com/mammooc/mammooc.org/wiki/Enable%20SSL) |
| Seed-Token for openHPI | `OPEN_HPI_TOKEN`      | individual |           | only necessary for `rake db:seed`; with a valid token, it will synchronize user data for `max@example.com` |
| Seed-Token for openSAP | `OPEN_SAP_TOKEN`      | individual |           |only necessary for `rake db:seed`; with a valid token, it will synchronize user data for `max@example.com` |
| SMTP with Mandrill     | `MANDRILL_USERNAME`   | individual |           | necessary for email dispatch; works with Mandrill, you have to create your own account for sending mails |
|                        | `MANDRILL_APIKEY`     | individual |           | necessary for email dispatch; works with Mandrill, you have to create your own account for sending mails |

----------------------------------------------------------------

These environment variables are for use in Production mode:

| Usage              | Environment variable      | Description |
|--------------------|---------------------------|-------------|
| Domain Name        | `DOMAIN`                  | always set to root URL of current production environment; necessary to differentiate between different production URLs |
| Amazon S3          | `AWS_ACCESS_KEY_ID`       | All Amazon S3 variables are necessary to get and push pictures to the Amazon S3 instance; if you want to create your own instance: [Wiki/AmazonS3](https://github.com/mammooc/mammooc.org/wiki/Set-up-Amazon-S3-Storage) |
|                    | `AWS_SECRET_ACCESS_KEY`   |  |
|                    | `AWS_REGION`              |  |
|                    | `S3_BUCKET_NAME`          |  |
| Coursera User Data | `COURSERA_CLIENT_ID`      | both variables are necessary to pull user data from Coursera; if you want to pull user data on your own, you have to create a developer account on Coursera |
|                    | `COURSERA_SECRET_KEY`     |  |
| Facebook Login     | `FACEBOOK_CLIENT_ID`      | both variables are necessary to use single-sign-on with Facebook; if you want to use single-sign-on with Facebook on your own, you have to create a developer account on Facebook | 
|                    | `FACEBOOK_SECRET_KEY`     |  |
| Google Login       | `GOOGLE_CLIENT_ID`        | both variables are necessary to use single-sign-on with Google; if you want to use single-sign-on with Google on your own, you have to create a developer account on Google |
|                    | `GOOGLE_SECRET_KEY`       |  |
| GitHub Login       | `GITHUB_CLIENT_ID`        | both variables are necessary to use single-sign-on with GitHub; if you want to use single-sign-on with GitHub on your own, you have to create a developer account on GitHub |
|                    | `GITHUB_SECRET_KEY`       |  |
| LinkedIn Login     | `LINKEDIN_CLIENT_ID`      | both variables are necessary to use single-sign-on with LinkedIn; if you want to use single-sign-on with LinkedIn on your own, you have to create a developer account on LinkedIn |
|                    | `LINKEDIN_SECRET_KEY`     |  |
| Twitter Login      | `TWITTER_CLIENT_ID`       | both variables are necessary to use single-sign-on with Twitter; if you want to use single-sign-on with twitter on your own, you have to create a developer account on Twitter |
|                    | `TWITTER_SECRECT_KEY`     |  |
| Windows Live Login | `WINDOWS_LIVE_CLIENT_ID`  | both variables are necessary to use single-sign-on with Windows Live; if you want to use single-sign-on with Windows Live on your own, you have to create a developer account on Windows Live |
|                    | `WINDOWS_LIVE_SECRET_KEY` |  |
| Amazon Login       | `AMAZON_CLIENT_ID`        | both variables are necessary to use single-sign-on with Amazon; if you want to use single-sign-on with Amazon on your own, you have to create a developer account on Amazon |
|                    | `AMAZON_SECRET_KEY`       |  |
| New Relic          | `NEW_RELIC_LICENSE_KEY`   | is necessary for gem Newrelic which provides bug reports and performance analysis |
| SMTP email dispatch| `SMTP_HOST`               | all varibles are necessary to deliver system generated emails |
|                    | `SMTP_PORT`               | default value: `'587'` |
|                    | `SMTP_USERNAME`           |  |
|                    | `SMTP_PASSWORD`           |  |
|                    | `SMTP_DOMAIN`             |  |
|                    | `SMTP_AUTHENTICATION`     | default value: `:plain`; possible values: `'plain', 'login', 'cram_md5'` |
