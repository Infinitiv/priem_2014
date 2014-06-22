class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :query, index: true
      t.text :input
      t.text :output

      t.timestamps
    end
  end
end
