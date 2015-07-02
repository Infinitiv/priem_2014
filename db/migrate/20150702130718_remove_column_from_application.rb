class RemoveColumnFromApplication < ActiveRecord::Migration
  def change
    remove_column :applications, :russian, :integer
    remove_column :applications, :chemistry, :integer
    remove_column :applications, :biology, :integer
    remove_column :applications, :ege, :boolean
    remove_column :applications, :ege_additional, :boolean
    remove_column :applications, :inner_exam, :boolean
  end
end
