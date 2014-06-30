class CampaignDate < ActiveRecord::Base
  belongs_to :education_form
  belongs_to :education_source
  belongs_to :campaign
end
