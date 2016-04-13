FROM ruby:2.3.0

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
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs
RUN gem install foreman

ENV APP_HOME /mammooc
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME

#install vim for easier in container file inspection
RUN apt-get install -y vim

# Prepare assets for production
RUN bundle exec rake assets:precompile

# Create cronjobs based on config/schedule.rb
RUN bundle exec whenever -w

# Download Root CA Certificates, add GTE for Windows Live Login and use this bundle for curl
RUN curl https://curl.haxx.se/ca/cacert.pem > cacert.pem
RUN curl https://www.digicert.com/CACerts/GTECyberTrustGlobalRoot.crt >> GTECyberTrustGlobalRoot.crt
RUN openssl x509 -inform DER -in GTECyberTrustGlobalRoot.crt -out GTECyberTrustGlobalRoot.pem -outform PEM
RUN cat GTECyberTrustGlobalRoot.pem >> cacert.pem
RUN rm GTECyberTrustGlobalRoot.crt GTECyberTrustGlobalRoot.pem
ENV SSL_CERT_FILE $APP_HOME/cacert.pem

# Make sure phantomjs is in the right place
# for this to work the script install_phantomjs.sh should be run
ENV PHANTOM_JS_NAME phantomjs-1.9.8-linux-x86_64
RUN mv $PHANTOM_JS_NAME/ /usr/local/share/
RUN ln -sf /usr/local/share/$PHANTOM_JS_NAME/bin/phantomjs /usr/local/bin
