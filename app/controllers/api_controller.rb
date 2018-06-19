class ApiController < ApplicationController
  def raw
    require "#{Rails.root}/lib/modules/mta.rb"
    render json: MTA::FeedParser.raw_feed
  end

  def update
    render json: $redis.get('realtime_update')
  end

  def line
    render json: MTA::FeedParser.line(params[:route_id])
  end

  def station
    render json: JSON.generate(Stop.trips_by_station(params[:station_id]))
  end

  def train
    render json: JSON.generate(Trip.send_info(params[:train_id]))
  end

end
