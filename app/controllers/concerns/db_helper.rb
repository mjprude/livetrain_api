module DBHelper
  extend ActiveSupport::Concern
  require File.expand_path(Rails.root + 'lib/modules/shapes', __FILE__)

  def self.query
    current_time = Time.now.to_i
    <<-SQL
      SELECT * FROM stops_by_trip x
      WHERE departure_time = (
         SELECT MAX(departure_time) FROM stops_by_trip y
         WHERE departure_time BETWEEN #{current_time - 600} AND #{current_time}
         AND x.id = y.id
      )
      UNION ALL
      SELECT * FROM stops_by_trip x
      WHERE arrival_time = (
         SELECT MIN(arrival_time) FROM stops_by_trip y
         WHERE arrival_time IS NOT NULL
         AND arrival_time > #{current_time}
         AND x.id = y.id
      )
      UNION ALL
      SELECT * FROM stops_by_trip x
      WHERE arrival_time = (
         SELECT arrival_time FROM stops_by_trip y
         WHERE arrival_time IS NOT NULL
         AND arrival_time > #{current_time}
         AND x.id = y.id
         ORDER BY arrival_time ASC
         LIMIT 1 OFFSET 1
      )
      UNION ALL
      SELECT * FROM stops_by_trip x
      WHERE arrival_time = (
         SELECT arrival_time FROM stops_by_trip y
         WHERE arrival_time IS NOT NULL
         AND arrival_time > #{current_time}
         AND x.id = y.id
         ORDER BY arrival_time ASC
         LIMIT 1 OFFSET 2
      )
      ORDER BY id, departure_time;
    SQL
  end

  def self.execute_sql
    ActiveRecord::Base.connection.execute(query)
  end

  def self.update_json(master_stops, master_routes)
    trips_array = execute_sql.group_by{ |row| row['id'] }.values

    trips_array.each_with_object([]) do |trip, json_ary|
      next if trip.length == 1
      if trip[0]['route'] == 'GS'
        last_stop = trip[0]
        stop1 = trip[1]
        route_obj = {
          trip_id: stop1['id'],
          route: stop1['route'],
          direction: stop1['direction'],
          updated: stop1['mta_timestamp'],
          lastStop: last_stop['stop_id'],
          lastDeparture: last_stop['departure_time'],
          stop1: stop1['stop_id'],
          path1: Shapes.get_path(stop1['route'], last_stop['stop_id'], stop1['stop_id'], master_stops, master_routes),
          arrival1: stop1['arrival_time'],
          departure1: nil,
          trip1Complete: false
        }
        json_ary << route_obj
      else
        # next if trip[0]['departure_time'].to_i > Time.now.to_i
        last_stop = trip[0]
        stop1 = trip[1]
        stop2 = trip[2]
        trip2Complete = (stop2 == nil)
        stop3 = trip[3]
        trip3Complete = (stop3 == nil)

        route_obj = {
          trip_id: stop1['id'],
          route: stop1['route'],
          direction: stop1['direction'],
          updated: stop1['mta_timestamp'],

          lastStop: last_stop['stop_id'],
          lastDeparture: last_stop['departure_time'],

          stop1: stop1['stop_id'],
          path1: Shapes.get_path(stop1['route'], last_stop['stop_id'], stop1['stop_id'], master_stops, master_routes),
          arrival1: stop1['arrival_time'],
          departure1: stop1['departure_time'],

          trip1Complete: false,
          trip2Complete: trip2Complete,
          trip3Complete: trip3Complete
        }

        if stop2
          route_obj[:stop2] = stop2['stop_id']
          route_obj[:path2] = Shapes.get_path(stop1['route'], stop1['stop_id'], stop2['stop_id'], master_stops, master_routes)
          route_obj[:arrival2] = stop2['arrival_time']
          route_obj[:departure2] = stop2['departure_time']
        end

        if stop3
          route_obj[:stop3] = stop3['stop_id']
          route_obj[:path3] = Shapes.get_path(stop1['route'], stop2['stop_id'], stop3['stop_id'], master_stops, master_routes)
          route_obj[:arrival3] = stop3['arrival_time']
          route_obj[:departure3] = stop3['departure_time']
        end
        json_ary << route_obj
      end
      json_ary
    end.to_json
  end
end



