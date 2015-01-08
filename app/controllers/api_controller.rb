class ApiController < ApplicationController
  def raw
    render json: MTA::FeedParser.raw_feed
  end

  def update
    begin
      f = Dir.glob("#{Rails.root}/app/assets/MTA_feeds/*").max_by {|f| File.mtime(f)}
      json = File.read(f)
      render json: JSON.parse(json)
    rescue
      sleep 1
      f = Dir.glob("#{Rails.root}/app/assets/MTA_feeds/*").max_by {|f| File.mtime(f)}
      json = File.read(f)
      render json: JSON.parse(json)
    end
  end

  def line
    render json: MTA::FeedParser.line(params[:route_id])
  end
end
