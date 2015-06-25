class CompetitiveGroup < ActiveRecord::Base
  belongs_to :campaign
  has_many :competitive_group_items
  has_many :entrance_test_items
  has_many :competitive_group_target_items
  has_many :target_organizations, through: :competitive_group_target_items
end
