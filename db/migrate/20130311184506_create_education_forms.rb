class CreateEducationForms < ActiveRecord::Migration
  def change
    create_table :education_forms do |t|
      t.integer :education_form_id, default: 11
      t.references :campaign

      t.timestamps
    end
  end
end
