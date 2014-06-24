class ApplicationsController < ApplicationController
  def index
    @applications = Application.order(:application_number).paginate(page: params[:page])
  end
  def show
    
  end
  def import
    Application.import(params[:file])
    redirect_to applications_url, notice: "Applications imported."
  end
end
