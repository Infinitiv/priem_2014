class TargetOrganization < ActiveRecord::Base
  belongs_to :competitive_group
  has_many :competitive_group_target_items
end
