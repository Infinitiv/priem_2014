class ApplicationsController < ApplicationController
before_action :set_application, only: [:show]
  def index
    last_campaign = Campaign.last
    @applications = Application.order(:application_number).where(campaign_id: last_campaign).paginate(page: params[:page])
  end
  def show
  end
  def import
    Application.import(params[:file])
    redirect_to applications_url, notice: "Applications imported."
  end
  def errors
    @errors = Application.errors
    @campaigns = Campaign.all
  end

  private

  def set_application
    @application = Application.includes([:education_documents, :identity_documents, :competitions]).find(params[:id])
  end
end
