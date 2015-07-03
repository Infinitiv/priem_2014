class AddColumnToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :checked, :date
    add_column :applications, :reg_number, :integer
  end
end
