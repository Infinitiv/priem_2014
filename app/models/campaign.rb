class Campaign < ActiveRecord::Base
  has_many :education_forms
  has_many :education_levels
  has_many :campaign_dates
  has_many :applications
end
