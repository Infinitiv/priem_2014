#encoding: utf-8
class Application < ActiveRecord::Base
  belongs_to :campaign
  has_many :competitive_groups, through: :campaign
  belongs_to :target_organization
  has_many :competitions
  has_many :competition_items, through: :competitions
  has_one :identity_document
  has_many :identity_document_types, through: :identity_document
  has_one :education_document
  has_many :education_document_types, through: :education_document
  has_many :marks
  has_many :entrance_test_items, through: :competitive_groups
  has_and_belongs_to_many :institution_achievements

  def self.import(file, default_campaign)
    accessible_attributes = column_names
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).to_a.in_groups_of(100, false) do |group|
      ActiveRecord::Base.transaction do
        group.each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          application = where(application_number: row["application_number"], campaign_id: default_campaign).first || new
          application.attributes = row.to_hash.slice(*accessible_attributes)
          application.campaign_id = default_campaign
          if application.save!
            IdentityDocument.import_from_row(row, application)
            EducationDocument.import_from_row(row, application)
            Competition.import_from_row(row, application)
            Mark.import_from_row(row, application)
            achievement_attestat = InstitutionAchievement.find_by_id_category(9)
            case row["achievement"]
            when 'TRUE'
              application.institution_achievements << achievement_attestat unless application.institution_achievements.include?(achievement_attestat)
            else
              application.institution_achievements.delete(achievement_attestat)
            end
          end
        end
      end
    end
  end
  
  def self.import_recommended(file, default_campaign)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).to_a.in_groups_of(100, false) do |group|
      ActiveRecord::Base.transaction do
        group.each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          application = where(application_number: row["application_number"], campaign_id: default_campaign).first
          competition = application.competitions.where(competition_item_id: row["competition_item_id"]).first
          competition.recommended_date = row["recommended_date"]
          competition.admission_date = row["admission_date"]
          competition.save!
        end
      end
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".ods" then Roo::OpenOffice.new(file.path)
    when ".csv" then Roo::CSV.new(file.path)
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  
  def fio
    [entrant_last_name, entrant_first_name, entrant_middle_name].compact.join(' ')
  end
  
  def summa
    marks.sum(:value)
  end
  
  def achiev_summa
    institution_achievements.sum(:max_value) > 10 ? 10 : institution_achievements.sum(:max_value)
  end
  
  def self.ege_to_txt(applications)
    ege_to_txt = ""
    applications.each do |application|
      ege_to_txt += "#{[application.entrant_last_name, application.entrant_first_name, application.entrant_middle_name].join('%')}%#{[application.identity_documents.last.identity_document_series, application.identity_documents.last.identity_document_number].join('%')}\r\n"
    end
    ege_to_txt.encode("cp1251")
  end
  
  def self.errors(default_campaign)
    errors = {}
    applications = default_campaign.applications.includes([:identity_document, :competitions])
    target_competition_entrants_array = applications.select(:id).joins(:competition_items).where("competition_items.name like ?", "%целев%")
    errors[:dups_numbers] = find_dups_numbers(applications)
    errors[:lost_numbers] = find_lost_numbers(applications)
    errors[:dups_entrants] = find_dups_entrants(applications)
    errors[:empty_target_entrants] = find_empty_target_entrants(target_competition_entrants_array, applications.select(:id).where("target_organization_id like ?", "%"))
    errors[:not_original_target_entrants] = find_not_original_target_entrants(target_competition_entrants_array, applications.select(:id).where.not(original_received_date: nil))
    errors
  end
  
  def self.find_dups_numbers(applications)
    find_dups_numbers = []
    h = applications.group(:application_number).count.select{|k, v| v > 1}
    h.each{|k, v| find_dups_numbers << Application.where(application_number: k)}
    find_dups_numbers
  end
  
  def self.find_lost_numbers(applications)
    application_numbers = applications.map(&:application_number)
    max_number = application_numbers.max
    max_number ? (1..max_number).to_a - application_numbers : []
  end
  
  def self.find_dups_entrants(applications)
    find_dups_entrants = {}
    applications.each do |a|
      sn = a.identity_document.sn
      find_dups_entrants[sn] ||= []
      find_dups_entrants[sn] << a
    end
    find_dups_entrants.select{|k, v| v.count > 1}
  end
  
  def self.find_empty_target_entrants(target_competition_entrants_array, target_organizations_array)
    (target_competition_entrants_array - target_organizations_array).sort
  end
                                                                                         
  def self.find_not_original_target_entrants(target_competition_entrants_array, original_received_array)
    (target_competition_entrants_array - original_received_array).sort
  end
  
  def self.competition(applications, admission_volume)
    applications_hash = {}
    applications.each do |application|
      competitions_hash = {}
      application.competitions.order(priority: :desc).each{|competition| competitions_hash[competition.competition_item_id] = competition.priority}
      applications_hash[application] = {}
      applications_hash[application][:summa] = application.summa
      applications_hash[application][:competitions] = competitions_hash
      applications_hash[application][:enrolled] = false
    end
    admission_volume_hash = {}
    admission_volume.each do |av|
      admission_volume_hash[av.direction_id] = {}
      admission_volume_hash[av.direction_id][:number_budget_o] = av.number_budget_o
      admission_volume_hash[av.direction_id][:number_paid_o] = av.number_paid_o
      admission_volume_hash[av.direction_id][:number_target_o] = av.number_target_o
      admission_volume_hash[av.direction_id][:number_quota_o] = av.number_quota_o
    end
    competitions = {}
    competitions[1] = admission_volume_hash[438][:number_budget_o]
    competitions[2] = admission_volume_hash[441][:number_budget_o]
    competitions[3] = admission_volume_hash[470][:number_budget_o]
    competitions[4] = admission_volume_hash[438][:number_paid_o]
    competitions[5] = admission_volume_hash[441][:number_paid_o]
    competitions[6] = admission_volume_hash[470][:number_paid_o]
    competitions[7] = admission_volume_hash[438][:number_target_o]
    competitions[8] = admission_volume_hash[441][:number_target_o]
    competitions[9] = admission_volume_hash[470][:number_target_o]
    competitions[10] = admission_volume_hash[438][:number_quota_o]
    competitions[11] = admission_volume_hash[441][:number_quota_o]
    competitions[12] = admission_volume_hash[470][:number_quota_o]
    applications_hash.select{|k, v| v[:competitions][13]}.each do |k, v|
      v[:competitions].each do |competition, priority|
        if competitions[1] > 0
          competitions[1] -= 1
          competitions[v[:enrolled]] += 1 if v[:enrolled] != false
          v[:enrolled] = 1
          v[:competitions].delete_if{|key, value| value > v[:competitions][13]}
        end
      end
    end
    applications_hash.select{|k, v| v[:competitions][14]}.each do |k, v|
      v[:competitions].each do |competition, priority|
        if competitions[2] > 0
          competitions[2] -= 1
          competitions[v[:enrolled]] += 1 if v[:enrolled] != false
          v[:enrolled] = 2
          v[:competitions].delete_if{|key, value| value > v[:competitions][14]}
        end
      end
    end
    applications_hash.select{|k, v| v[:competitions][15]}.each do |k, v|
      v[:competitions].each do |competition, priority|
        if competitions[3] > 0
          competitions[3] -= 1
          competitions[v[:enrolled]] += 1 if v[:enrolled] != false
          v[:enrolled] = 3
          v[:competitions].delete_if{|key, value| value > v[:competitions][15]}
        end
      end
    end
    applications_hash.select{|k, v| v[:competitions][16]}.each do |k, v|
      v[:competitions].each do |competition, priority|
        if competitions[4] > 0
          competitions[4] -= 1
          competitions[v[:enrolled]] += 1 if v[:enrolled] != false
          v[:enrolled] = 4
          v[:competitions].delete_if{|key, value| value > v[:competitions][16]}
        end
      end
    end
    applications_hash.select{|k, v| v[:competitions][17]}.each do |k, v|
      v[:competitions].each do |competition, priority|
        if competitions[5] > 0
          competitions[5] -= 1
          competitions[v[:enrolled]] += 1 if v[:enrolled] != false
          v[:enrolled] = 5
          v[:competitions].delete_if{|key, value| value > v[:competitions][17]}
        end
      end
    end
    applications_hash.select{|k, v| v[:competitions][18]}.each do |k, v|
      v[:competitions].each do |competition, priority|
        if competitions[6] > 0
          competitions[6] -= 1
          competitions[v[:enrolled]] += 1 if v[:enrolled] != false
          v[:enrolled] = 6
          v[:competitions].delete_if{|key, value| value > v[:competitions][18]}
        end
      end
    end
    applications_hash.each do |k, v|
      v[:competitions].each do |competition, priority|
        if  !(13..18).to_a.include?(competition) && competitions[competition] > 0
          competitions[competition] -= 1
          competitions[v[:enrolled]] += 1 if v[:enrolled] != false
          v[:enrolled] = competition
          v[:competitions].delete_if{|key, value| value > v[:competitions][competition]}
        end
      end
    end
    competitions[1] = competitions[10] + competitions[7]
    competitions[2] = competitions[11] + competitions[8]
    competitions[3] = competitions[12] + competitions[9]
    applications_hash.each do |k, v|
      v[:competitions].each do |competition, priority|
        if  !(13..18).to_a.include?(competition) && competitions[competition] > 0
          competitions[competition] -= 1
          competitions[v[:enrolled]] += 1 if v[:enrolled] != false
          v[:enrolled] = competition
          v[:competitions].delete_if{|key, value| value > v[:competitions][competition]}
        end
      end
    end
    applications_hash
  end
end
