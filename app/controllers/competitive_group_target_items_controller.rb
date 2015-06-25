class CompetitiveGroupTargetItemsController < ApplicationController
  before_action :set_competitive_group, only: [:create, :destroy]
  before_action :set_competitive_group_target_item, only: [:destroy]

  def index
  end
  
  def show
  end
  
  def new
  end
  
  def create
    @competitive_group_target_item = @competitive_group.competitive_group_target_items.new(competitive_group_target_item_params)
    if @competitive_group_target_item.save
      set_competitive_group_target_items
      respond_to{|format| format.js}
    end
  end
  
  def update
  end
  
  def destroy
    @competitive_group_target_item.destroy
    set_competitive_group_target_items
    respond_to{|format| format.js}
  end
  
  private
 
  def set_competitive_group
    @competitive_group = CompetitiveGroup.find(params[:competitive_group_target_item][:competitive_group_id])
  end
  
  def set_competitive_group_target_items
    @competitive_group_target_items = @competitive_group.competitive_group_target_items.order(:direction_id)
  end
  
  def competitive_group_target_item_params
    params.require(:competitive_group_target_item).permit(:competitive_group_id, :direction_id, :education_level_id, :number_target_o, :number_target_oz, :number_target_z, :target_organization_id)
  end
  
  def set_competitive_group_target_item
    @competitive_group_target_item = CompetitiveGroupTargetItem.find(params[:competitive_group_target_item][:competitive_group_target_item_id])
  end
end