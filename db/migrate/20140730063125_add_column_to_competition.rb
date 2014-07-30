class AddColumnToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :recommended_date, :date
  end
end
