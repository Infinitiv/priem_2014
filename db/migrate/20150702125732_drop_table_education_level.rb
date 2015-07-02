class DropTableEducationLevel < ActiveRecord::Migration
  def change
    drop_table :education_levels
  end
end
