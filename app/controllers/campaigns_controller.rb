class CampaignsController < ApplicationController
before_action :set_campaign, only: [:show, :destroy, :new]

  def index
    set_campaigns
    @campaign = Campaign.new
    @current_year = Time.now.year
  end
  
  def show
    @competitive_group = @campaign.competitive_groups.new
    @competitive_groups = @campaign.competitive_groups.where.not(id: nil)
    @target_organizations = TargetOrganization.order(:target_organization_name).load
  end
  
  def new
  end
  
  def create
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      set_campaigns
      respond_to{|format| format.js}
    end
  end
  
  def update
  end
  
  def destroy
    @campaign.destroy
    set_campaigns
    respond_to{|format| format.js}
  end
  
  private
  def set_campaign
    @campaign = Campaign.includes(:campaign_dates, :competitive_groups, :competitive_group_items, :competitive_group_target_items, :target_organizations).find(params[:id])
  end
  
  def set_campaigns
    @campaigns = Campaign.order(:year_start).load.reverse
  end
  
  def campaign_params
    params.require(:campaign).permit(:name, :year_start, :year_end, :status_id, :is_for_krym)
  end
end