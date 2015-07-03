class CreateMarks < ActiveRecord::Migration
  def change
    create_table :marks do |t|
      t.references :application, index: true
      t.references :entrance_test_item, index: true
      t.integer :value
      t.string :form
      t.date :checked

      t.timestamps
    end
  end
end
