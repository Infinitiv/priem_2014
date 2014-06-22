class RequestsController < ApplicationController
  def new
    @request = Request.new
    @queries = Query.order(:name)
  end
end