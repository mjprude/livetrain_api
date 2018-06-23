class AddIndexToStops < ActiveRecord::Migration
  def change
    add_index :stops, [:trip_id, :departure_time, :arrival_time]
  end
end
