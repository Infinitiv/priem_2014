class AddColumnToCompetitiveGroupTargetItem < ActiveRecord::Migration
  def change
    add_reference :competitive_group_target_items, :competitive_group, index: true
  end
end
