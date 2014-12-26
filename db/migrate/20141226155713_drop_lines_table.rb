class DropLinesTable < ActiveRecord::Migration
  def change
    drop_table :lines
  end
end
