class CompetitiveGroup < ActiveRecord::Base
  belongs_to :campaign
  has_many :competitive_group_items
  has_and_belongs_to_many :target_organizations
  has_many :entrance_test_items
end
