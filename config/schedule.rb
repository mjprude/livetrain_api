#!/usr/bin/ruby
require 'clockwork'
require "./config/boot"
require "./config/environment"
require './app/workers/feed_worker'
require './app/workers/db_flush'

module Clockwork
  handler do |job|
    f = File.open("./log/worker.log", "a+")
      f.write("\nPerforming #{job} at #{Time.now}\n")
    f.close
  end

  every 60.seconds, 'feed_worker' do
    FeedWorker.perform_async
  end

  every(1.day, 'flush_database', :at => '04:00') do
    DBFlush.perform_async
  end
end