web: bundle exec passenger start -p $PORT -e $RACK_ENV --max-pool-size $PASSENGER_MAX_POOL_SIZE
worker: bundle exec sidekiq -C ./config/sidekiq.yml
