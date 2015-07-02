class DropTableEducationForm < ActiveRecord::Migration
  def change
    drop_table :education_forms
  end
end
