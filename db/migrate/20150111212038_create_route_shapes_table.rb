class CreateRouteShapesTable < ActiveRecord::Migration
  def change
    create_table :route_shapes do |t|
      t.string :route_id
      t.string :service_id
      t.string :trip_id
      t.string :headsign
      t.string :shape_id

      t.timestamps
    end
  end
end
