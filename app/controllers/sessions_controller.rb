class SessionsController < ApplicationController
  def create
    campaign = Campaign.find_by_id(params[:campaign_id])
    if campaign then
      session[:campaign_id] = campaign.id
      redirect_to :back
    else
      redirect_to login_url, alert: "Error"
    end
  end
  
  def destroy
    session[:campaign_id] = nil
    redirect_to :back
  end
end
