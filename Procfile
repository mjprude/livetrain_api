scheduler: nohup bundle exec clockwork config/schedule.rb &
worker: nohup bundle exec sidekiq -e production &
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
