class CompetitiveGroupItem < ActiveRecord::Base
  belongs_to :competitive_group
  has_many :competition_items
end
