class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.integer :application_number
      t.integer :campaign_id
      t.string :entrant_last_name
      t.string :entrant_first_name
      t.string :entrant_middle_name
      t.integer :russian
      t.integer :chemistry
      t.integer :biology
      t.integer :target_speciality_id
      t.integer :target_organization_id
      t.integer :nationality_type_id
      t.integer :region_id
      t.integer :gender_id
      t.date :birth_date
      t.boolean :need_hostel, :default => false
      t.boolean :lech_budget, :default => false
      t.boolean :ped_budget, :default => false
      t.boolean :stomat_budget, :default => false
      t.boolean :lech_paid, :default => false
      t.boolean :ped_paid, :default => false
      t.boolean :stomat_paid, :default => false
      t.boolean :special_entrant, default: false
      t.boolean :ege, default: false
      t.boolean :ege_additional, default: false
      t.boolean :inner_exam, default: false
      t.boolean :olympionic, default: false
      t.boolean :benefit, default: false
      t.date :registration_date
      t.date :original_received_date
      t.date :last_deny_day
      t.integer :status_id, :default => 2
      

      t.timestamps
    end
  end
end
