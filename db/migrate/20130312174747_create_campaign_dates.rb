class CreateCampaignDates < ActiveRecord::Migration
  def change
    create_table :campaign_dates do |t|
      t.integer :course, default: 1
      t.integer :education_level_id, default: 5
      t.integer :education_form_id, default: 11
      t.integer :education_source_id
      t.integer :stage
      t.date :date_start
      t.date :date_end
      t.date :date_order
      t.references :campaign

      t.timestamps
    end
    add_index :campaign_dates, :campaign_id
  end
end
