FROM ruby:2.5

RUN apt-get update -qq && apt-get install -y build-essential

# for imageMagick
RUN apt-get install -y imagemagick

# for cronjobs
RUN apt-get install -y cron

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqtwebkit4 libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs
RUN gem install foreman

ENV APP_HOME /mammooc
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME

# Create cronjobs based on config/schedule.rb
RUN bundle exec whenever -w

# Download Root CA Certificates, add GTE for Windows Live login and use this bundle for curl
RUN curl -L https://curl.haxx.se/ca/cacert.pem > cacert.pem
RUN curl -L https://www.digicert.com/CACerts/GTECyberTrustGlobalRoot.crt >> GTECyberTrustGlobalRoot.crt
RUN openssl x509 -inform DER -in GTECyberTrustGlobalRoot.crt -out GTECyberTrustGlobalRoot.pem -outform PEM
RUN cat GTECyberTrustGlobalRoot.pem >> cacert.pem
RUN rm GTECyberTrustGlobalRoot.crt GTECyberTrustGlobalRoot.pem
ENV SSL_CERT_FILE $APP_HOME/cacert.pem
