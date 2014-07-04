class Application < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :target_organization
  has_many :competitions
  has_many :identity_documents
  has_many :education_documents

  def self.import(file)
    accessible_attributes = column_names
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).to_a.in_groups_of(100, false) do |group|
      ActiveRecord::Base.transaction do
        group.each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          application = find_by_application_number(row["application_number"]) || new
          application.attributes = row.to_hash.slice(*accessible_attributes)
          if application.save!
            IdentityDocument.import_from_row(row, application)
            EducationDocument.import_from_row(row, application)
            Competition.import_from_row(row, application)
          end
        end
      end
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".ods" then Roo::Openoffice.new(file.path, nil, :ignore)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  
  def fio
    [entrant_last_name, entrant_first_name, entrant_middle_name].compact.join(' ')
  end
  
  def summa
    [russian, chemistry, biology].compact.sum
  end
  
  def self.errors
    errors = {}
    Campaign.all.each do |campaign|
      applications = campaign.applications
      errors[campaign] = {}
      errors[campaign][:dups_numbers] = find_dups_numbers(applications.map(&:application_number))
      errors[campaign][:dups_entrants] = find_dups_entrants(IdentityDocument.joins(:application).where(applications: {id: applications.map(&:id)}).map{|d| "#{d.identity_document_series}#{d.identity_document_number}"})
    end
    errors
  end
  
  def self.find_dups_numbers(array)
    array.select{|i| array.count(i) > 1}
  end
  
  def self.find_dups_entrants(array)
    array.select{|i| array.count(i) > 1}
  end
end
