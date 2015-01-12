class RouteShape < ActiveRecord::Base

	def self.get_shapes_by_route(route_id)
		self.where('route_id LIKE ?', "#{route_id}").map do |shape|
			shape.shape_id
		end.uniq
	end

	def self.get_uniq_shapes
		self.all.map { |shape| shape.shape_id }.uniq
	end

	def self.get_routes_by_shape(shape_id)
		self.where('shape_id LIKE ?', "#{shape_id}").map do |shape|
			shape.route_id
		end.uniq
	end

	def self.routes_by_all_shapes
		get_uniq_shapes.map {|shape| {shape=> get_routes_by_shape(shape)} }
	end

	def self.get_headsigns_by_shape(shape_id)
		self.where('shape_id LIKE ?', "#{shape_id}").map do |shape|
			shape.headsign
		end.uniq
	end

	def self.headsigns_by_all_shapes
		get_uniq_shapes.map {|shape| {shape=> get_headsigns_by_shape(shape)} }		
	end



	def self.get_uniq_shape_ends
		self.all.map { |shape| shape.shape_id[-4..-2] }.uniq
	end

	def self.get_headsigns_by_shape_end(shape_end)
		self.where('shape_id LIKE ?', "%#{shape_end}%").map do |shape|
			{shape.shape_id[0] => shape.headsign}
		end.uniq
	end

	def self.headsigns_by_all_shape_ends
		get_uniq_shape_ends.map {|shape| {shape=> get_headsigns_by_shape_end(shape)} }		
	end

	def self.get_routes_by_shape_end(shape_end)
		self.where('shape_id LIKE ?', "%#{shape_end}").map do |shape|
			shape.route_id
		end.uniq
	end

	def self.routes_by_all_shape_ends
		get_uniq_shape_ends.map {|shape| {shape=> get_routes_by_shape_end(shape)} }		
	end



	def self.get_base_shape_ids
		self.all.map do |shape| 
			day, time, shape = shape.trip_id.split('_')
			shape[0..5]
		end.uniq
	end

	def self.get_headsigns_by_base_shape(base_shape)
		self.where('trip_id LIKE ?', "%#{base_shape}%").map do |shape|
			shape.headsign
		end.uniq
	end

	def self.get_headsigns_by_all_base_shapes
		@return_hash = {}
		get_base_shape_ids.each {|shape| @return_hash[shape] = get_headsigns_by_base_shape(shape)[0] }
		@return_hash
	end

	def self.write_json_with_trips
		f = File.open(Rails.root + 'app/assets/static_MTA/uniq_route_shapes.txt', 'w')
		f.write(get_headsigns_by_all_base_shapes.to_json)
		f.close
	end

end


