module DBHelper

  def query
    current_time = 1419294150 #Time.now.to_i
    <<-SQL
      SELECT * FROM stops_by_trip x
      WHERE departure_time = (
         SELECT MAX(departure_time) FROM stops_by_trip y
         WHERE departure_time BETWEEN 0 AND #{current_time}
         AND x.mta_trip_id = y.mta_trip_id
      )
      UNION ALL
      SELECT * FROM stops_by_trip x
      WHERE arrival_time = (
         SELECT MIN(arrival_time) FROM stops_by_trip y
         WHERE arrival_time IS NOT NULL
         AND arrival_time > #{current_time}
         AND x.mta_trip_id = y.mta_trip_id
      )
      UNION ALL
      SELECT * FROM stops_by_trip x
      WHERE arrival_time = (
         SELECT arrival_time FROM stops_by_trip y
         WHERE arrival_time IS NOT NULL
         AND arrival_time > #{current_time}
         AND x.mta_trip_id = y.mta_trip_id
         ORDER BY arrival_time ASC
         LIMIT 1 OFFSET 1
      )
      UNION ALL
      SELECT * FROM stops_by_trip x
      WHERE arrival_time = (
         SELECT arrival_time FROM stops_by_trip y
         WHERE arrival_time IS NOT NULL
         AND arrival_time > #{current_time}
         AND x.mta_trip_id = y.mta_trip_id
         ORDER BY arrival_time ASC
         LIMIT 1 OFFSET 2
      )
      ORDER BY mta_trip_id, departure_time;
    SQL
  end

  def execute_sql
    ActiveRecord::Base.connection.execute(query)
  end

  def update_json
    trips_array = execute_sql.group_by{ |row| row['mta_trip_id'] }.values

    trips_array.each_with_object([]) do |trip, json_ary|
      if trip.length == 1
        #handle shuttles and ignore the rest
      else
        last_stop = trip[0]
        stop1 = trip[1]
        stop2 = trip[2]
        trip2Complete = (stop2 == nil)
        stop3 = trip[3]
        trip3Complete = (stop3 == nil)

        route_obj = {
          trip_id: 't' + stop1['mta_trip_id'].gsub('.', '_'),
          route: stop1['route'],
          direction: stop1['direction'],
          updated: stop1['mta_timestamp'],

          lastStop: last_stop['stop_id'],
          lastDeparture: last_stop['departure_time'],

          stop1: stop1['stop_id'],
          path1: Shapes.get_path(stop1['route'], last_stop['stop_id'], stop1['stop_id']),
          arrival1: stop1['arrival_time'],
          departure1: stop1['departure_time'],

          trip1Complete: false,
          trip2Complete: trip2Complete,
          trip3Complete: trip3Complete
        }

        if stop2
          route_obj[:stop2] = stop2['stop_id']
          route_obj[:path2] = Shapes.get_path(stop1['route'], stop1['stop_id'], stop2['stop_id'])
          route_obj[:arrival2] = stop2['arrival_time']
          route_obj[:departure2] = stop2['departure_time']
        end

        if stop3
          route_obj[:stop3] = stop3['stop_id']
          route_obj[:path3] = Shapes.get_path(stop1['route'], stop2['stop_id'], stop3['stop_id'])
          route_obj[:arrival3] = stop3['arrival_time']
          route_obj[:departure3] = stop3['departure_time']
        end
        json_ary << route_obj
      end
    end


  end







  def update_json2
    all_trains = []
    current_time = 1419294150 #Time.now.to_i

    Trip.where(route: ['1', '6']).each do |trip|

      if trip.start_time - current_time < 60

        last_stop = trip.stops.where('departure_time < ?',  current_time).order('departure_time DESC').first
        last_stop ||= trip.stops.where('departure_time > ?',  current_time).order('departure_time ASC').first

        future_stops = trip.stops.where('arrival_time > ?',  current_time).order('arrival_time ASC')

        stop1 = future_stops[0]

        stop2 = future_stops[1]
        trip2Complete = (stop2 == nil)

        stop3 = future_stops[2]
        trip3Complete = (stop3 == nil)



        begin
          if stop1 && last_stop
            route_obj = {
              trip_id: 't' + trip.mta_trip_id.gsub('.', '_'),
              route: trip.route,
              direction: trip.direction,
              updated: trip.mta_timestamp,

              lastStop: last_stop.stop_id,
              lastDeparture: last_stop.departure_time,

              stop1: stop1.stop_id,
              path1: Shapes.get_path(trip.route, last_stop.stop_id, stop1.stop_id),
              arrival1: stop1.arrival_time,
              departure1: stop1.departure_time,

              trip1Complete: false,
              trip2Complete: trip2Complete,
              trip3Complete: trip3Complete
            }
          end

          if stop2
            route_obj[:stop2] = stop2.stop_id
            route_obj[:path2] = Shapes.get_path(trip.route, stop1.stop_id, stop2.stop_id)
            route_obj[:arrival2] = stop2.arrival_time
            route_obj[:departure2] = stop2.departure_time
          end

          if stop3
            route_obj[:stop3] = stop3.stop_id
            route_obj[:path3] = Shapes.get_path(trip.route, stop2.stop_id, stop3.stop_id)
            route_obj[:arrival3] = stop3.arrival_time
            route_obj[:departure3] = stop3.departure_time
          end

        rescue Exception => e
          e
          binding.pry
        end
        all_trains << route_obj
      end
    end
    all_trains.compact.to_json
  end

end
helpers DBHelper


# SELECT * FROM stops_by_trip x WHERE departure_time = ( SELECT MAX(departure_time) FROM stops_by_trip y WHERE departure_time BETWEEN 0 AND 1419294150 AND x.mta_trip_id = y.mta_trip_id ) UNION ALL SELECT * FROM stops_by_trip x WHERE arrival_time = ( SELECT MIN(arrival_time) FROM stops_by_trip y WHERE arrival_time IS NOT NULL AND arrival_time > 1419294150 AND x.mta_trip_id = y.mta_trip_id ) UNION ALL SELECT * FROM stops_by_trip x WHERE arrival_time = ( SELECT arrival_time FROM stops_by_trip y WHERE arrival_time IS NOT NULL AND arrival_time > 1419294150 AND x.mta_trip_id = y.mta_trip_id ORDER BY arrival_time ASC LIMIT 1 OFFSET 1 ) UNION ALL SELECT * FROM stops_by_trip x WHERE arrival_time = ( SELECT arrival_time FROM stops_by_trip y WHERE arrival_time IS NOT NULL AND arrival_time > 1419294150 AND x.mta_trip_id = y.mta_trip_id ORDER BY arrival_time ASC LIMIT 1 OFFSET 2 ) ORDER BY mta_trip_id, departure_time;