class CreateCompetitiveGroups < ActiveRecord::Migration
  def change
    create_table :competitive_groups do |t|
      t.references :campaign
      t.integer :course, default: 1
      t.string :name, default: ""

      t.timestamps
    end
    add_index :competitive_groups, :campaign_id
  end
end
