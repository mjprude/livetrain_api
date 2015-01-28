class Trip < ActiveRecord::Base
  has_many :stops, dependent: :destroy

  def self.send_info(train_id)
    train = Trip.find(train_id)

    stops = []
    train.stops.order(:departure_time).each do |stop|
      stops << {
        mta_stop_id: stop.stop_id[0..-2],
        arrival_time: stop.arrival_time,
        departure_time: stop.departure_time
      }
    end

    return_info = {
      trip_id: train.id,
      direction: train.direction,
      stops: stops
    }
  end

end