class ApplicationsController < ApplicationController
before_action :set_application, only: [:show]
  def index
    last_campaign = Campaign.last
    @applications = Application.order(:application_number).where(campaign_id: @default_campaign)
  end
  def show
    @marks = @application.marks.joins(:entrance_test_item).where(entrance_test_items: {subject_id: [11, 4, 1]})
  end
  def import
    Application.import(params[:file], @default_campaign.id)
    redirect_to applications_url, notice: "Applications imported."
  end
  
  def import_recommended
    Application.import_recommended(params[:file])
    redirect_to applications_url, notice: "Recommended imported."
  end
  
  def errors
    @errors = Application.errors(@default_campaign)
  end
  
  def competition
    @applications_hash = Application.competition(@default_campaign)
  end
  
  def ege_to_txt
    applications = Application.includes(:identity_document).where(campaign_id: @default_campaign, last_deny_day: nil)
    ege_to_txt = Application.ege_to_txt(applications)
    send_data ege_to_txt, :filename => "ege #{Time.now.to_date}.csv", :type => 'text/plain', :disposition => "attachment"
  end

  private

  def set_application
    @application = Application.includes([:education_document, :education_document_types, :identity_document, :identity_document_types, :competitions, :marks, :entrance_test_items, :institution_achievements]).find(params[:id])
  end
end
