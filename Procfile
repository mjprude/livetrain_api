scheduler: bundle exec whenever --update-crontab livetrain
worker: bundle exec sidekiq
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb