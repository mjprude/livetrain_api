class CreateViewStopsByTrip < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE VIEW stops_by_trip AS
      SELECT
        trips.mta_trip_id,
        trips.route,
        trips.direction,
        trips.mta_timestamp,
        stops.stop_id,
        stops.departure_time,
        stops.arrival_time
      FROM trips
      INNER JOIN stops
      ON stops.trip_id = trips.id
    SQL
  end
  def self.down
    execute <<-SQL
      DROP VIEW stops_by_trip
    SQL
  end
end
