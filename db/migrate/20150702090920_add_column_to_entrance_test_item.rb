class AddColumnToEntranceTestItem < ActiveRecord::Migration
  def change
    add_column :entrance_test_items, :subject_id, :integer
  end
end
