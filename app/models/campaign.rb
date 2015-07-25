class Campaign < ActiveRecord::Base
  has_many :campaign_dates
  has_many :applications
  has_many :admission_volumes
  has_many :competitive_groups
  has_many :competitive_group_items, through: :competitive_groups
  has_many :competition_items, through: :competitive_group_items
  has_many :competitive_group_target_items, through: :competitive_groups
  has_many :target_organizations, through: :competitive_group_target_items
  has_many :entrance_test_items, through: :competitive_groups
end
