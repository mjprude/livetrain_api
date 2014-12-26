class DropStationsTable < ActiveRecord::Migration
  def change
    drop_table :stations
  end
end
