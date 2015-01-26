class Trip < ActiveRecord::Base
  has_many :stops, dependent: :destroy

  def self.send_info(train_id)
    train = Trip.find(train_id)
    stops = []

    train.stops.each do |stop|
      
    end

    return_info = {
      trip_id: train.id
      stops: stops
    }
  end
end