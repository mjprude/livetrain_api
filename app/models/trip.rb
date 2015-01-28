class Trip < ActiveRecord::Base
  has_many :stops, dependent: :destroy

  def self.send_info(train_id)
    @destinations = JSON.parse(File.read(Rails.root + 'app/assets/static_MTA/uniq_route_shapes.json'))

    train = Trip.find(train_id)

    stops = []
    train.stops.order(:departure_time).each do |stop|
      stops << {
        mta_stop_id: stop.stop_id[0..-2],
        arrival_time: stop.arrival_time,
        departure_time: stop.departure_time,
      }
    end

    time, shape_id = train.mta_trip_id.split('_')

    return_info = {
      trip_id: train.id,
      route: train.route,
      direction: train.direction,
      stops: stops,
      destination: @destinations[shape_id[0..5]] == nil ? "Modified Service" : @destinations[shape_id[0..5]].split(' ').map{|word| word.capitalize}.join(' ')
    }
  end

end