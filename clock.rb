require 'clockwork'
require './modules/feed'

module Clockwork

  handler do |job|
    puts "#{job} running..."
  end

  every(30.seconds, Feed.parse)

end