class AddColumnToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :is_for_krym, :boolean, default: false
  end
end
