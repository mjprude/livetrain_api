class ApiController < ApplicationController
  def raw
    render json: MTA::FeedParser.raw_feed
  end

  def update
    render json: DBHelper::update_json
  end

  def line
    render josn: MTA::FeedParser.line(params[:route_id])
  end
end
