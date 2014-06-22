class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :name, default: ""

      t.timestamps
    end
  end
end
