class Stop < ActiveRecord::Base
  belongs_to :trip

  def self.trips_by_station(station)
    @destinations = JSON.parse(File.read(Rails.root + 'app/assets/static_MTA/uniq_route_shapes.txt'))

  	upcoming_stops = self.where("stop_id LIKE ?", "#{station}%").select {|stop| stop.departure_time && stop.future_trip? }
    upcoming_stops.sort! { |x, y| x.departure_time <=> y.departure_time }
  	sorted_stops = {
      'station_number' => station,
      'southbound' => [],
      'northbound' => []
    }

  	upcoming_stops.each do |stop|
      matching_trip = Trip.find(stop.trip_id)
      route = matching_trip.route
      time, shape_id = matching_trip.mta_trip_id.split('_')
      stop_info = {
        'trip_id' => matching_trip.id,
        'stop_id' => stop.id,
        'route' => route.gsub('X', ''),
        'timestamp' => stop.departure_time,
        'destination' => @destinations[shape_id[0..5]] == nil ? nil : @destinations[shape_id[0..5]].split(' ').map{|word| word.capitalize}.join(' '),
        'min_till_train' => stop.min_till_train
      }
      sorted_stops[stop.stop_id[-1] == 'S' ? 'southbound' : 'northbound'] << stop_info
  	end

    sorted_stops['southbound'] = limit_returns(sorted_stops['southbound'], 3)
    sorted_stops['northbound'] = limit_returns(sorted_stops['northbound'], 3)
    sorted_stops
  end

  def future_trip?
    self.departure_time - Time.now.to_i > 0
  end

  def self.limit_returns(potential_stops, stop_limit)
    route_counts = Hash.new(0)
    potential_stops.select do |stop|
      route_counts[stop['route']] += 1
      route_counts[stop['route']] < (stop_limit + 1)
    end
  end

  def min_till_train
    (self.departure_time - Time.now.to_i) / 60
  end


end