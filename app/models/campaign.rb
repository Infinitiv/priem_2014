class Campaign < ActiveRecord::Base
  has_many :education_forms
  has_many :education_levels
  has_many :campaign_dates
  has_many :applications
  has_many :admission_volumes
  has_many :competitive_groups
  has_many :competitive_group_items, through: :competitive_groups
  has_many :competitive_group_target_items, through: :competitive_groups
  has_many :target_organizations, through: :competitive_group_target_items
end
