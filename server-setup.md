https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-0://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04

https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-on-ubuntu-14-04-using-rvm

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-16-04

https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-redis-on-ubuntu-16-04

For reverse-proxy NGINX config to run on port 80 (only available to root by
default)
https://www.digitalocean.com/community/tutorials/how-to-set-up-a-node-js-application-for-production-on-ubuntu-16-04

RAILS_ENV=production
RACK_ENV=production #probably not necessary
MTA_REALTIME_API_KEY=a-valid-key

create db user in postgres
possibly change peer connection on local to md5

# nohup bundle exec sidekiq -e production &
bundle exec sidekiq -d -L log/sidekiq.log -C config/sidekiq.yml -e production
nohup bundle exec clockwork config/schedule.rb &
nohup bundle exec rails s &
