#!/usr/bin/ruby

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



set :output, "./cron_log.log"

every 1.minutes do
  runner "FeedWorker.perform_async"
  runner "FeedWorker2.perform_async"
end