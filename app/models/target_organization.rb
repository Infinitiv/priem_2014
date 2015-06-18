class TargetOrganization < ActiveRecord::Base
  has_and_belongs_to_many :competitive_groups
  has_many :applications
  has_many :competitive_group_target_items
end
