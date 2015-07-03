class CompetitionItem < ActiveRecord::Base
  belongs_to :competitive_group_item
  has_one :competitive_group, through: :competitive_group_item
end
