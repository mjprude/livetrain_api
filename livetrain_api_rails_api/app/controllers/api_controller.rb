class ApiController < ApplicationController
  def raw
    render json: MTA::FeedParser.raw_feed
  end

  def update
    f = File.read("#{Rails.root}" + '/app/assets/MTA_feeds/2015-01-06_17.16.13_realtime.json')
    render json: JSON.parse(f)
  end

  def line
    render json: MTA::FeedParser.line(params[:route_id])
  end
end
