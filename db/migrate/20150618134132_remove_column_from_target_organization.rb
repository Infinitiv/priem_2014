class RemoveColumnFromTargetOrganization < ActiveRecord::Migration
  def change
    remove_column :target_organizations, :competitive_group_id
  end
end
