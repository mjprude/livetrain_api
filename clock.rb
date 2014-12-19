require 'clockwork'
require "sidekiq.rb"

module Clockwork
  handler do |job|
    puts "Fetching MTA feed..."
  end

  every(30.seconds, MTAWorker.perform)

end