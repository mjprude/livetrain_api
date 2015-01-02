class StopsByTrip < ActiveRecord::Base
  self.table_name = 'stops_by_trip' #refers to view
  self.primary_key = 'mta_trip_id'
end