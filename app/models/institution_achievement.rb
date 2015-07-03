class InstitutionAchievement < ActiveRecord::Base
  belongs_to :campaign
  has_and_belongs_to_many :applications
end
