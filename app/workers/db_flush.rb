#!/usr/bin/ruby

require 'sidekiq'
class DBFlush
  include Sidekiq::Worker
  def perform
    Trip.delete_all
    Stop.delete_all
  end
end