require 'bundler'
Bundler.require

require 'sinatra/activerecord/rake'
require './connection'
require './mta_assets/gtfs-realtime.pb.rb'
require './mta_assets/nyct-subway.pb.rb'
require './modules/mta.rb'
require './models/trip.rb'
require './models/stop.rb'

ROOT_PATH = Dir.pwd
Dir[ROOT_PATH+"/lib/*.rb"].each{ |file| require file }
Dir[ROOT_PATH+"/helpers/*.rb"].each{ |file| require file }

# namespace :clockwork do
#   desc 'Start the clockwork daemon'
#   task :start => :environment do
#     pid = fork do
#       $stdout.reopen("/dev/null")
#       $stdout.sync = true
#       $stderr.reopen($stdout)
#       include Clockwork

#       handler do |job_class|
#         Resque.enqueue(job_class)
#       end

#       every(30.seconds, Gameday::FrequentUpdates)
#       every(1.day, Gameday::DailyJob, :at => "01:30")
#       run
#     end
#     Process.detach(pid)
#     File.open("./tmp/clockwork_#{Rails.env}_pid.txt", "w") do |file|
#       file << pid
#     end
#   end

#   desc "Stop the clockwork daemon"
#   task :stop => :environment do
#     pid = File.read("./tmp/clockwork_#{Rails.env}_pid.txt").to_i
#     Process.kill(1, pid)
#   end

#   desc 'restart the clockwork daemon'
#   task :restart => [:stop, :start]
# end

namespace :db do

  desc 'Deletes all trips and stops from database'
  task :clear_trips do
    conn = PG.connect({
      dbname: 'mta_realtime'
      })
    conn.exec('DELETE FROM trips;')
    conn.exec('DELETE FROM stops;')
    conn.close
  end

end

desc "Show Routes for This File"
task :routes do
  puts "******************"

  def capitalize_http(route)
    route
    .gsub('get', '    GET  ')
    .gsub('put', '    PUT  ')
    .gsub('patch', '  PATCH  ')
    .gsub('post', '   POST  ')
    .gsub('delete', ' DELETE  ')
  end

  def get_routes(path)
    route_regex = /(get|post|delete|patch|put) '\/.*(?= )/
    app = File.readlines(path)
    puts "Routes in #{path}\n******************"
    app.grep(route_regex).each do |line|
      puts capitalize_http(route_regex.match(line)[0])
    end
    puts "******************"
  end

  if File.exist?('app.rb')
    get_routes('app.rb')
  else
    Dir['./controllers/*.rb'].each{ |controller| get_routes(controller) }
  end

end

namespace :mta do

  ##########################################################
  # Use this task to retrieve MTA feed data
  ##########################################################
  desc 'run feed retriever'
  task :feed do
    # ************ Helper Methods *************
    def create_stops_from_entity(entity, trip)
      entity[:trip_update][:stop_time_update].each do |stop_update|
        Stop.create({
          trip_id: trip.id,
          stop_id: MTA::Stop.stop_id(stop_update),
          arrival_time: MTA::Stop.arrival_time(stop_update),
          departure_time: MTA::Stop.departure_time(stop_update),
          })
      end
    end

    def update_existing_stops(entity, trip)
      entity[:trip_update][:stop_time_update].each do |stop_update|
        if stop = trip.stops.find_by({stop_id: MTA::Stop.stop_id(stop_update)})
          stop.update({
            arrival_time: MTA::Stop.arrival_time(stop_update),
            departure_time: MTA::Stop.departure_time(stop_update),
          })
        end
      end
    end

    def new_trip_start_time(feed_entity)
      if upcoming_departure_timestamp = MTA::Stop.departure_time(feed_entity[:trip_update][:stop_time_update][0])
        upcoming_departure_timestamp
      else
        @feed_timestamp
      end
    end

    # *************** FEED RETRIEVAL PROCESS ******************

    # Get the raw data
    @transit_realtime_data = TransitRealtime::FeedMessage.parse(HTTParty.get("http://datamine.mta.info/mta_esi.php?key=#{ENV['MTA_REALTIME_API_KEY']}&feed_id=1")).to_hash
    ### Maybe come up with a way to handle situations where transit_realtime_data is not available?

    # Pull out the timestamp of the retrieved feed
    @feed_timestamp = MTA::Feed.mta_timestamp(@transit_realtime_data)

    # PURELY FOR DEBUGGING !!!
    @updated_trips = @transit_realtime_data[:entity].count {|entity| entity[:trip_update] }
    @num_created_trips = 0
    @num_updated_trips = 0
    @start_times_updated = 0

    # Use the feed to update all entities
    @transit_realtime_data[:entity].each do |entity|
      if entity[:trip_update]
        # Check to see if the update applies to any trips currently in the db
        if existing_trip = Trip.find_by({mta_trip_id: MTA::Entity.mta_trip_id(entity)})
          unless existing_trip.mta_timestamp == @feed_timestamp
            if existing_trip.start_time > @feed_timestamp
              existing_trip.update({
                  mta_timestamp: @feed_timestamp,
                  stops_remaining: MTA::Entity.stops_remaining(entity),
                  start_time: MTA::Stop.departure_time(entity[:trip_update][:stop_time_update][0]) ? MTA::Stop.departure_time(entity[:trip_update][:stop_time_update][0]) : @feed_timestamp
                })
              @start_times_updated += 1 # PURELY FOR DEBUGGING !!!
            else
              existing_trip.update({
                  mta_timestamp: @feed_timestamp,
                  stops_remaining: MTA::Entity.stops_remaining(entity),
                })
            end
            update_existing_stops(entity, existing_trip)
            @num_updated_trips += 1 # PURELY FOR DEBUGGING !!!
          end
        else
          # If the trip doesn't exist yet, create it
          if !entity[:trip_update][:stop_time_update].empty?
            new_trip = Trip.create({
                mta_timestamp: @feed_timestamp,
                mta_trip_id: MTA::Entity.mta_trip_id(entity),
                stops_remaining: MTA::Entity.stops_remaining(entity),
                route: MTA::Entity.route(entity),
                direction: MTA::Entity.direction(entity),
                start_time: new_trip_start_time(entity)
              })
            create_stops_from_entity(entity, new_trip)
            @num_created_trips += 1 # PURELY FOR DEBUGGING !!!
          end
        end
      end
    end

    # Delete completed trips from the db
    @deletions = 0
    Trip.where('stops_remaining < ?', 3).each do |trip|
      if Time.now.to_i > trip.mta_timestamp + 120
        @deletions += 1
        trip.destroy
      end
    end

    puts "Total MTA Updates: #{@updated_trips}"
    puts " Created trips: #{@num_created_trips}"
    puts " Updated trips: #{@num_updated_trips}"
    puts " Deleted trips: #{@deletions}"
    puts "Start Time Upd: #{@start_times_updated}"
    puts "      DB trips: #{Trip.all.count}"
  end
end