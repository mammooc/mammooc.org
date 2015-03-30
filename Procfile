web: bundle exec unicorn -p $PORT -E $RACK_ENV -c ./config/unicorn.rb
redis: redis-server
sidekiq: bundle exec sidekiq -C ./config/sidekiq.yml
