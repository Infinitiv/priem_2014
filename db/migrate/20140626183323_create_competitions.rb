class CreateCompetitions < ActiveRecord::Migration
  def change
    create_table :competitions do |t|
      t.references :application, index: true
      t.references :competition_item, index: true
      t.integer :priority
      t.date :admission_date

      t.timestamps
    end
  end
end
