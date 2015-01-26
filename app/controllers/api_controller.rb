class ApiController < ApplicationController
  def raw
    require "#{Rails.root}/lib/modules/mta.rb"
    render json: MTA::FeedParser.raw_feed
  end

  def update
    # begin
      f = Dir.glob("#{Rails.root}/app/assets/MTA_feeds/*").max_by {|f| File.mtime(f)}
      json = File.read(f)
      render json: JSON.parse(json)
    # rescue
    #   sleep 1
    #   f = Dir.glob("#{Rails.root}/app/assets/MTA_feeds/*").max_by {|f| File.mtime(f)}
    #   json = File.read(f)
    #   render json: JSON.parse(json)
    # end
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
