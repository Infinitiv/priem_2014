class CampaignDatesController < ApplicationController
  before_action :set_campaign, only: [:create, :destroy]
  before_action :set_campaign_date, only: [:destroy]

  def index
  end
  
  def show
  end
  
  def new
  end
  
  def create
    @campaign_date = @campaign.campaign_dates.new(campaign_date_params)
    if @campaign_date.save
      set_campaign_dates
      respond_to{|format| format.js}
    end
  end
  
  def update
  end
  
  def destroy
    @campaign_date.destroy
    set_campaign_dates
    respond_to{|format| format.js}
  end
  
  private
  def set_campaign
    @campaign = Campaign.find_by_id(params[:campaign_date][:campaign_id])
  end
  
  def set_campaign_date
    @campaign_date = CampaignDate.find(params[:id])
  end
  
  def set_campaign_dates
    @campaign_dates = @campaign.campaign_dates.order(:name)
  end
  
  def campaign_date_params
    params.require(:campaign_date).permit(:campaign_id, :course, :education_level_id, :education_form_id, :education_source_id, :stage, :date_start, :date_end, :date_order)
  end
end