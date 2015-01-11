class Stop < ActiveRecord::Base
  belongs_to :trip

  def self.trips_by_station(station)
  	upcoming_stops = self.where("stop_id LIKE ?", "#{station}%").select {|stop| stop.arrival_time && stop.future_trip? }
  	sorted_stops = {
      'station_number' => station,
      'southbound' => {
        'local' => [],
        'express' => []
        },
      'northbound' => {
        'local' => [],
        'express' => []
      }
    }
  	upcoming_stops.each do |stop|
      trip_id = stop.trip_id
      route = Trip.find(trip_id).route
      stop_info = {
        'trip_id' => trip_id,
        'route' => route,
        'timestamp' => stop.arrival_time,
        'min_till_train' => stop.min_till_arrival
      }
      sorted_stops[stop.stop_id[-1] == 'S' ? 'southbound' : 'northbound'][['1', '6'].include?(route) ? 'local' : 'express' ] << stop_info
  	end
    sorted_stops['southbound']['local'].sort! {|x, y| x['timestamp'].to_i <=> y['timestamp'].to_i }
    sorted_stops['southbound']['express'].sort! {|x, y| x['timestamp'].to_i <=> y['timestamp'].to_i }
    sorted_stops['northbound']['local'].sort! {|x, y| x['timestamp'].to_i <=> y['timestamp'].to_i }
    sorted_stops['northbound']['express'].sort! {|x, y| x['timestamp'].to_i <=> y['timestamp'].to_i }
    sorted_stops
  end

  def future_trip?
    self.arrival_time - Time.now.to_i > 0
  end

  def min_till_arrival
    (self.arrival_time - Time.now.to_i) / 60
  end


end