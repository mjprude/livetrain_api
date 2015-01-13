#!/usr/bin/ruby
require 'clockwork'
require "./config/boot"
require "./config/environment"
require './app/workers/feed_worker'
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
#

#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever



# set :output, "./cron_log.log"

# every 1.minutes do
#   runner "FeedWorker.perform_async"
#   runner "FeedWorker2.perform_async"
# end
module Clockwork
  handler do |job|
    f = File.open("./log/worker.log", "a+")
      f.write("\nPerforming #{job} at #{Time.now}\n")
    f.close
  end

  every 60.seconds, 'feed_worker' do
    FeedWorker.perform_async
  end
end