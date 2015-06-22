class CompetitiveGroupsController < ApplicationController
  before_action :set_campaign, only: [:create, :destroy]
  before_action :set_competitive_group, only: [:destroy]

  def index
  end
  
  def show
  end
  
  def new
  end
  
  def create
    @competitive_group = @campaign.competitive_groups.new(competitive_group_params)
    if @competitive_group.save
      set_competitive_groups
      respond_to{|format| format.js}
    end
  end
  
  def update
  end
  
  def destroy
    @competitive_group.destroy
    set_competitive_groups
    respond_to{|format| format.js}
  end
  
  private
  def set_campaign
    @campaign = Campaign.find_by_id(params[:competitive_group][:campaign_id])
  end
  
  def set_competitive_group
    @competitive_group = CompetitiveGroup.find(params[:id])
  end
  
  def set_competitive_groups
    @competitive_groups = @campaign.competitive_groups.order(:name)
  end
  
  def competitive_group_params
    params.require(:competitive_group).permit(:name, :campaign_id, :course)
  end
end