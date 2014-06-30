class CreateTargetOrganizations < ActiveRecord::Migration
  def change
    create_table :target_organizations do |t|
      t.references :competitive_group
      t.string :target_organization_name, default: ""

      t.timestamps
    end
    add_index :target_organizations, :competitive_group_id
  end
end
