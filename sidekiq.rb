require 'bundler'
Bundler.require

$redis = Redis.new

class MTAWorker
  include Sidekiq::Worker


  def perform
    $redis.lpush(`rake mta:feed`)
  end


end