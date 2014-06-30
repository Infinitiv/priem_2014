class CreateEducationLevels < ActiveRecord::Migration
  def change
    create_table :education_levels do |t|
      t.integer :course, default: 1
      t.integer :education_level_id, default: 5
      t.references :campaign

      t.timestamps
    end
  end
end
