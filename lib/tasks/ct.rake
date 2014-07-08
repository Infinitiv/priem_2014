namespace :ct do
  desc "Check an Application"
  task check_app: :environment do
    require 'builder'
    last_campaign = Campaign.last
    applications = Application.select(:id).where(campaign_id: last_campaign).limit(10)
    case Rails.env
      when 'development' then url = 'priem.edu.ru:8000'
      when 'production' then url = '127.0.0.1:8080'
    end
    method = '/checkapplication/single'
    applications.each do |application|
      params = {}
      params[:application_id] = application.id
      request = Request.data(method, params)
      uri = URI.parse('http://' + url + '/import/importservice.svc')
      http = Net::HTTP.new(uri.host, uri.port)
      headers = {'Content-Type' => 'text/xml'}
      response = http.post(uri.path + method, request, headers)
      puts request
      puts response.body
    end
  end

end
