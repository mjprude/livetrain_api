require File.expand_path(Rails.root + 'lib/modules/feed', __FILE__)

class MTAUpdate
  def initialize
    @process_start_time = Time.now

    mta_api_response = HTTParty.get("http://datamine.mta.info/mta_esi.php?key=#{ENV['MTA_REALTIME_API_KEY']}&feed_id=1")
    l_train_response = HTTParty.get("http://datamine.mta.info/mta_esi.php?key=#{ENV['MTA_REALTIME_API_KEY']}&feed_id=2")

    @transit_realtime_data = TransitRealtime::FeedMessage.parse(mta_api_response).to_hash
    l_data = TransitRealtime::FeedMessage.parse(l_train_response).to_hash
    @transit_realtime_data[:entity] += l_data[:entity]

    @feed_timestamp = MTA::Feed.mta_timestamp(@transit_realtime_data)

    # for logging
    @updated_trips = @transit_realtime_data[:entity].count {|entity| entity[:trip_update] }
    @num_created_trips = 0
    @num_updated_trips = 0
    @start_times_updated = 0
    @deletions = 0
    @master_stops = JSON.parse(File.read(Rails.root + 'lib/assets/mta_assets/sorted_subway_stops.json'))
    @master_routes = JSON.parse(File.read(Rails.root + 'lib/assets/mta_assets/sorted_subway_routes.json'))
  end

  def update_and_create
    all_trips = []
    all_stops = []
    Trip.transaction do
      @transit_realtime_data[:entity].each do |entity|
        next unless entity[:trip_update]
        if existing_trip = Trip.find_by({mta_trip_id: MTA::Entity.mta_trip_id(entity)})
          update_existing_trip(entity, existing_trip)
        else
          new_trip = create_trip_from_entity(entity)
          all_trips << new_trip
          all_stops << create_stops_from_entity(entity, new_trip)
        end
      end

      all_trips.each(&:save!)
      all_stops.flatten.each(&:save!)
    end
  end

  def delete_complete
    Trip.where('stops_remaining < ?', 3).each do |trip|
      if Time.now.to_i > trip.mta_timestamp + 120
        @deletions += 1
        trip.destroy
      end
    end
  end

  def write_json
    current_time = Time.now
    date, time, zone = current_time.to_s.split(' ')

    string = "#{Rails.root}" + "/app/assets/MTA_feeds/" + date + '_' + time.gsub(':', '.') + "_realtime.json"

    payload = DBHelper::update_json(@master_stops, @master_routes)
    f = File.open(string, 'a+')
      f.write(payload)
    f.close

    `find app/assets/MTA_feeds/ -name *.json -type f -mmin +3 -delete`
  end

  def log
    f = File.open("#{Rails.root}/log/worker.log", "a+")
      f.write("\n\n\nProcess Start Time: #{@process_start_time}")
      f.write("\nTrip Update Time: #{@trip_update_execution_time}")
      f.write("\nExecution time: #{Time.now}  /  #{Time.now.to_i}")
      f.write("\nTotal MTA Updates: #{@updated_trips}")
      f.write("\n Created trips: #{@num_created_trips}")
      f.write("\n Updated trips: #{@num_updated_trips}")
      f.write("\n Deleted trips: #{@deletions}")
      f.write("\nStart Time Upd: #{@start_times_updated}")
      f.write("\n      DB trips: #{Trip.all.count}")
    f.close
  end

  private

  def create_stops_from_entity(entity, trip)
    entity[:trip_update][:stop_time_update].map do |stop_update|
      trip.stops.build({
        trip_id: trip.id,
        stop_id: MTA::Stop.stop_id(stop_update),
        arrival_time: MTA::Stop.arrival_time(stop_update),
        departure_time: MTA::Stop.departure_time(stop_update),
      })
    end
  end

  def update_existing_stops(entity, trip)
    updated_stops = {}
    existing_stops = trip.stops
    entity[:trip_update][:stop_time_update].each do |stop_update|
      if stop = existing_stops.find { |stop| stop.stop_id == MTA::Stop.stop_id(stop_update) }
        updated_stops[stop.id] = {
          arrival_time: MTA::Stop.arrival_time(stop_update),
          departure_time: MTA::Stop.departure_time(stop_update),
        }
      end
    end
    Stop.update(updated_stops.keys, updated_stops.values)
  end

  def new_trip_start_time(feed_entity)
    if upcoming_departure_timestamp = MTA::Stop.departure_time(feed_entity[:trip_update][:stop_time_update][0])
      upcoming_departure_timestamp
    else
      @feed_timestamp
    end
  end

  def create_trip_from_entity(entity)
    if !entity[:trip_update][:stop_time_update].empty?
      @num_created_trips += 1
      Trip.new({
        mta_timestamp: @feed_timestamp,
        mta_trip_id: MTA::Entity.mta_trip_id(entity),
        stops_remaining: MTA::Entity.stops_remaining(entity),
        route: MTA::Entity.route(entity),
        direction: MTA::Entity.direction(entity),
        start_time: new_trip_start_time(entity)
      })
    end
  end

  def update_existing_trip(entity, existing_trip)
    return nil if existing_trip.mta_timestamp == @feed_timestamp
    if existing_trip.start_time > @feed_timestamp
      existing_trip.update({
        mta_timestamp: @feed_timestamp,
        stops_remaining: MTA::Entity.stops_remaining(entity),
        start_time: MTA::Stop.departure_time(entity[:trip_update][:stop_time_update][0]) ? MTA::Stop.departure_time(entity[:trip_update][:stop_time_update][0]) : @feed_timestamp
        })

      @start_times_updated += 1
    else
      existing_trip.update({
        mta_timestamp: @feed_timestamp,
        stops_remaining: MTA::Entity.stops_remaining(entity),
        })
    end
    update_existing_stops(entity, existing_trip)
    @num_updated_trips += 1
  end
end
