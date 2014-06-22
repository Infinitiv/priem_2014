class Request < ActiveRecord::Base
  require 'builder'
  belongs_to :query
  
  def self.data(method)
    case method
    when '/dictionary'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
      end
    when '/institutioninfo'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
      end
    end
  end
  
  def self.auth_data(root)
    auth_data = ::Builder::XmlMarkup.new(indent: 2)
    a = AuthData.first
    root.AuthData do |ad|
      ad.Login a.login
      ad.Pass a.pass
    end
  end
end
