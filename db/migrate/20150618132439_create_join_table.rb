class CreateJoinTable < ActiveRecord::Migration
  def change
    create_join_table :competitive_groups, :target_organizations do |t|
      t.index [:competitive_group_id, :target_organization_id]
      t.index [:target_organization_id, :competitive_group_id]
    end
  end
end
