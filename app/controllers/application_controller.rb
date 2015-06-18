class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :set_default_campaign
  before_action :show_default_campaign
  
  private
  
  def show_default_campaign
    @default_campaign_name = @default_campaign.name if @default_campaign
  end
  
  def set_default_campaign
      @default_campaign ||= Campaign.find_by_id(session[:campaign_id]) if session[:campaign_id]
  end
end
