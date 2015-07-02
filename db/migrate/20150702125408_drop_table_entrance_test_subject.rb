class DropTableEntranceTestSubject < ActiveRecord::Migration
  def change
    drop_table :entrance_test_subjects
  end
end
