class RemoveColumnFromCompetitionItem < ActiveRecord::Migration
  def change
    remove_column :competition_items, :competitive_group_id, :integer
  end
end
