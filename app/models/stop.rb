class Stop < ActiveRecord::Base
  belongs_to :trip

  def self.trips_by_station(station)
  	upcoming_stops = self.where("stop_id LIKE ?", "#{station}%").select {|stop| stop.departure_time && stop.future_trip? }
    upcoming_stops.sort! { |x, y| x.departure_time <=> y.departure_time }
  	sorted_stops = {
      'station_number' => station,
      'southbound' => [],
      'northbound' => []
    }

  	upcoming_stops.each do |stop|
      trip_id = stop.trip_id
      route = Trip.find(trip_id).route
      stop_info = {
        'trip_id' => trip_id,
        'route' => route,
        'timestamp' => stop.departure_time,
        'min_till_train' => stop.min_till_train
      }
      sorted_stops[stop.stop_id[-1] == 'S' ? 'southbound' : 'northbound'] << stop_info
  	end

    sorted_stops['southbound'] = limit_returns(sorted_stops['southbound'])
    sorted_stops['northbound'] = limit_returns(sorted_stops['northbound'])
    sorted_stops
  end

  def future_trip?
    self.departure_time - Time.now.to_i > 0
  end

  def self.limit_returns(potential_stops)
    route_counts = Hash.new(0)
    potential_stops.select do |stop|
      route_counts[stop['route']] += 1
      route_counts[stop['route']] < 4
    end
  end

  def min_till_train
    (self.departure_time - Time.now.to_i) / 60
  end


end