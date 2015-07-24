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
2. we use passenger
 - to start the application: ```passenger start```
 - the application is available at: ```localhost:3000``` 
 - stop the application: ```passenger stop```

For manual test in a deployed version:
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
