class AddContractToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :contract, :boolean, default: false
  end
end
