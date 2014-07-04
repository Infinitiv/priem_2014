class RequestsController < ApplicationController
  before_action :set_request, only: [:show]
  def index
    @requests = Request.order(:id).paginate(:page => params[:page])
  end
  def show
    
  end
  def new
    @request = Request.new
    @queries = Query.order(:name)
    @campaigns = Campaign.order(:year_start)
  end
  
  def create
    case Rails.env
      when 'development' then url = 'priem.edu.ru:8000'
      when 'production' then url = '127.0.0.1:8080'
    end
    method = '/' + Query.find(params[:request][:query_id]).name
    request = Request.data(method, params)
    uri = URI.parse('http://' + url + '/import/importservice.svc')
    http = Net::HTTP.new(uri.host, uri.port)
    headers = {'Content-Type' => 'text/xml'}
    response = http.post(uri.path + method, request, headers)
    @request = Request.new(query_id: params[:request][:query_id], input: request, output: response.body)

    respond_to do |format|
      if @request.save
        format.html { redirect_to @request, notice: 'Request was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end
  
  private
  
  def set_request
    @request = Request.find params[:id]
  end
end