class CreateCompetitionItems < ActiveRecord::Migration
  def change
    create_table :competition_items do |t|
      t.string :name, default: ""

      t.timestamps
    end
  end
end
