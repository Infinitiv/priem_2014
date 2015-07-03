class AddColumnToCompetitionItem < ActiveRecord::Migration
  def change
    add_column :competition_items, :code, :integer
  end
end
