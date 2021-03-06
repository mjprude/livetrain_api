#!/usr/bin/ruby

require 'sidekiq'
class FeedWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    start_time = Time.now
    feed = MTAUpdate.new
    api_time = Time.now
    puts "MTA call: #{api_time - start_time}"

    feed.update_and_create
    db_time = Time.now
    puts "Database insertions: #{db_time - api_time}"

    feed.delete_complete
    delete_time = Time.now
    puts "Database deletions: #{delete_time - db_time}"

    feed.write_json
    json_time = Time.now
    puts "JSON creation: #{json_time - delete_time}"

    feed.log
  end

end

# class FeedWorker
#   include Sidekiq::Worker

#   def create_stops_from_entity(entity, trip)
#     entity[:trip_update][:stop_time_update].each do |stop_update|
#       Stop.create({
#         trip_id: trip.id,
#         stop_id: MTA::Stop.stop_id(stop_update),
#         arrival_time: MTA::Stop.arrival_time(stop_update),
#         departure_time: MTA::Stop.departure_time(stop_update),
#         })
#     end
#   end

#   def update_existing_stops(entity, trip)
#     entity[:trip_update][:stop_time_update].each do |stop_update|
#       if stop = trip.stops.find_by({stop_id: MTA::Stop.stop_id(stop_update)})
#         stop.update({
#           arrival_time: MTA::Stop.arrival_time(stop_update),
#           departure_time: MTA::Stop.departure_time(stop_update),
#           })
#       end
#     end
#   end

#   def new_trip_start_time(feed_entity)
#     if upcoming_departure_timestamp = MTA::Stop.departure_time(feed_entity[:trip_update][:stop_time_update][0])
#       upcoming_departure_timestamp
#     else
#       @feed_timestamp
#     end
#   end

#   # *************** FEED RETRIEVAL PROCESS ******************
#   def perform
#     # if ENV['RAILS_ENV'] == 'production'
#     #   ActiveRecord::Base.establish_connection({:password => ENV['LIVETRAIN_API_DATABASE_PASSWORD'], :database => 'livetrain_api_production', :username => 'livetrain_api', :adapter => 'postgresql', :host => 'localhost'})
#     # end
#     # Get the raw data
#     @process_start_time = Time.now
#     @transit_realtime_data = TransitRealtime::FeedMessage.parse(HTTParty.get("http://datamine.mta.info/mta_esi.php?key=#{ENV['MTA_REALTIME_API_KEY']}&feed_id=1")).to_hash
#     ### Maybe come up with a way to handle situations where transit_realtime_data is not available?

#     # Pull out the timestamp of the retrieved feed
#     @feed_timestamp = MTA::Feed.mta_timestamp(@transit_realtime_data)

#     # PURELY FOR DEBUGGING !!!
#     @updated_trips = @transit_realtime_data[:entity].count {|entity| entity[:trip_update] }
#     @num_created_trips = 0
#     @num_updated_trips = 0
#     @start_times_updated = 0

#     # Use the feed to update all entities
#     @transit_realtime_data[:entity].each do |entity|
#       if entity[:trip_update]
#         # Check to see if the update applies to any trips currently in the db
#         if existing_trip = Trip.find_by({mta_trip_id: MTA::Entity.mta_trip_id(entity)})
#           unless existing_trip.mta_timestamp == @feed_timestamp
#             if existing_trip.start_time > @feed_timestamp
#               existing_trip.update({
#                 mta_timestamp: @feed_timestamp,
#                 stops_remaining: MTA::Entity.stops_remaining(entity),
#                 start_time: MTA::Stop.departure_time(entity[:trip_update][:stop_time_update][0]) ? MTA::Stop.departure_time(entity[:trip_update][:stop_time_update][0]) : @feed_timestamp
#                 })
#               @start_times_updated += 1 # PURELY FOR DEBUGGING !!!
#             else
#               existing_trip.update({
#                 mta_timestamp: @feed_timestamp,
#                 stops_remaining: MTA::Entity.stops_remaining(entity),
#                 })
#             end
#             update_existing_stops(entity, existing_trip)
#             @num_updated_trips += 1 # PURELY FOR DEBUGGING !!!
#           end
#         else
#           # If the trip doesn't exist yet, create it
#           if !entity[:trip_update][:stop_time_update].empty?
#             new_trip = Trip.create({
#               mta_timestamp: @feed_timestamp,
#               mta_trip_id: MTA::Entity.mta_trip_id(entity),
#               stops_remaining: MTA::Entity.stops_remaining(entity),
#               route: MTA::Entity.route(entity),
#               direction: MTA::Entity.direction(entity),
#               start_time: new_trip_start_time(entity)
#               })
#             create_stops_from_entity(entity, new_trip)
#             @num_created_trips += 1 # PURELY FOR DEBUGGING !!!
#           end
#         end
#       end
#     end

#     # Delete completed trips from the db
#     @deletions = 0
#     Trip.where('stops_remaining < ?', 3).each do |trip|
#       if Time.now.to_i > trip.mta_timestamp + 120
#         @deletions += 1
#         trip.destroy
#       end
#     end

#     @trip_update_execution_time = Time.now

#     # Prepare JSON and save to tmp file
#     current_time = Time.now
#     date, time, zone = current_time.to_s.split(' ')

#     string = "#{Rails.root}" + "/app/assets/MTA_feeds/" + date + '_' + time.gsub(':', '.') + "_realtime.json"

#     payload = DBHelper::update_json

#     f = File.open(string, 'a+')
#     f.write(payload)
#     f.close

#     `find app/assets/MTA_feeds/ -name *.json -type f -mmin +3 -delete`

#     f = File.open("#{Rails.root}/log/worker.log", "a+")
#       f.write("\n\n\nProcess Start Time: #{@process_start_time}")
#       f.write("\nTrip Update Time: #{@trip_update_execution_time}")
#       f.write("\nExecution time: #{Time.now}  /  #{Time.now.to_i}")
#       f.write("\nTotal MTA Updates: #{@updated_trips}")
#       f.write("\n Created trips: #{@num_created_trips}")
#       f.write("\n Updated trips: #{@num_updated_trips}")
#       f.write("\n Deleted trips: #{@deletions}")
#       f.write("\nStart Time Upd: #{@start_times_updated}")
#       f.write("\n      DB trips: #{Trip.all.count}")
#     f.close
#   end
# end