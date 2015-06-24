class CompetitiveGroupItemsController < ApplicationController
  before_action :set_competitive_group, only: [:create, :destroy]
  before_action :set_competitive_group_item, only: [:destroy]

  def index
  end
  
  def show
  end
  
  def new
  end
  
  def create
    @competitive_group_item = @competitive_group.competitive_group_items.new(competitive_group_item_params)
    if @competitive_group_item.save
      set_competitive_group_items
      respond_to{|format| format.js}
    end
  end
  
  def update
  end
  
  def destroy
    @competitive_group_item.destroy
    set_competitive_group_items
    respond_to{|format| format.js}
  end
  
  private
 
  def set_competitive_group
    @competitive_group = CompetitiveGroup.find(params[:competitive_group_item][:competitive_group_id])
  end
  
  def set_competitive_group_items
    @competitive_group_items = @competitive_group.competitive_group_items.order(:direction_id)
  end
  
  def competitive_group_item_params
    params.require(:competitive_group_item).permit(:competitive_group_id, :direction_id, :education_level_id, :number_budget_o, :number_paid_o, :number_target_o, :number_quota_o)
  end
  
  def set_competitive_group_item
    @competitive_group_item = CompetitiveGroupItem.find(params[:competitive_group_item][:competitive_group_item_id])
  end
end