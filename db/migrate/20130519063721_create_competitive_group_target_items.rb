class CreateCompetitiveGroupTargetItems < ActiveRecord::Migration
  def change
    create_table :competitive_group_target_items do |t|
      t.references :target_organization
      t.integer :education_level_id, default: 5
      t.integer :number_target_o, default: 0
      t.integer :number_target_oz, default: 0
      t.integer :number_target_z, default: 0
      t.integer :direction_id

      t.timestamps
    end
    add_index :competitive_group_target_items, :target_organization_id
  end
end
