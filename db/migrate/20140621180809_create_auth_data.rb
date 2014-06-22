class CreateAuthData < ActiveRecord::Migration
  def change
    create_table :auth_data do |t|
      t.string :login
      t.string :pass
      t.integer :institution_id

      t.timestamps
    end
  end
end
