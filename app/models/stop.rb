class Stop < ActiveRecord::Base
  belongs_to :trip

  def self.trips_by_station(station)
  	upcoming_stops = self.where("stop_id LIKE ?", "#{station}%").select {|stop| stop.arrival_time && stop.future_trip? }
  	sorted_stops = {
      'southbound' => [],
      'northbound' => []
    }
  	upcoming_stops.each do |stop|
      trip_id = stop.trip_id

      stop_info = {
        'trip_id' => trip_id,
        'route' => Trip.find(trip_id).route,
        'timestamp' => stop.arrival_time,
        'min_till_train' => stop.min_till_arrival
      }
      sorted_stops[stop.stop_id[-1] == 'S' ? 'southbound' : 'northbound'] << stop_info
  	end
    sorted_stops
  end

  def future_trip?
    self.arrival_time - Time.now.to_i > 0
  end

  def min_till_arrival
    (self.arrival_time - Time.now.to_i) / 60
  end


end