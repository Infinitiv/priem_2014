class CreateCompetitionItems < ActiveRecord::Migration
  def change
    create_table :competition_items do |t|
      t.string :name, default: ""
      t.integer :finance_source_id
      t.integer :competitive_group_id
      t.integer :competitive_group_item_id

      t.timestamps
    end
  end
end
