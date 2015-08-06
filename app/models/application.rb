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
          competitions = Competition.joins(:application).where(applications: {application_number: row["application_number"], campaign_id: default_campaign})
          competitions.where.not(admission_date: nil).each{|c| c.update_attributes(admission_date: nil)}
          competitions.joins(:competition_item).where(competition_items: {code: row["competition_item_id"]}).each{|c| c.update_attributes(admission_date: row["admission_date"])}
        end
      end
    end
  end
  
  def self.import_contracts(file, default_campaign)
    competition_items = default_campaign.competition_items
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).to_a.each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      competitions = Competition.joins(:application).where(applications: {application_number: row["application_number"], campaign_id: default_campaign})
      competitions.each{|c| c.update_attributes(contract: false)}
      competition_items.each do |competition_item|
        competition = competitions.find_by_competition_item_id(competition_item.id) if row[competition_item.code.to_s]
        competition.update_attributes(contract: true) if competition && row[competition_item.code.to_s]
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
      ege_to_txt += "#{[application.entrant_last_name, application.entrant_first_name, application.entrant_middle_name].join('%')}%#{[application.identity_document.identity_document_series, application.identity_document.identity_document_number].join('%')}\r\n"
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
  
  def self.competition(default_campaign)
    applications = Application.select([:id, :application_number, :entrant_last_name, :entrant_first_name, :entrant_middle_name, :campaign_id, :original_received_date, :last_deny_day, :target_organization_id]).includes(:marks, :competitions).where(campaign_id: default_campaign, last_deny_day: nil).where.not(original_received_date: nil).select{|a| a.marks.map(&:value).select{|m| m > 35}.count == 3}
    achiev_apps = Application.where(campaign_id: default_campaign).joins(:institution_achievements).map(&:id)
    marks = Mark.order(:entrance_test_item_id).joins(:application).where(applications: {campaign_id: default_campaign}).group_by(&:application_id).map{|a, ms| {a => ms.map{|m| m.value}}}.inject(:merge)
    app_competitions = Competition.order(:priority).includes(:competition_item).joins(:application).where(applications: {campaign_id: default_campaign}).group_by(&:application_id).map{|a, cs| {a => cs.map{|c| c.competition_item.code}}}.inject(:merge)
    contract_app_competitions = Competition.order(:priority).includes(:competition_item).joins(:application).where(applications: {campaign_id: default_campaign}, competition_items: {code: (4..6).to_a}, contract: false).group_by(&:application_id).map{|a, cs| {a => cs.map{|c| c.competition_item.code}}}.inject(:merge)
    contract_app_competitions.each do |k, v|
      app_competitions[k] - contract_app_competitions[k]
    end
    
    applications_hash = {}
    applications.each do |application|
      applications_hash[application] = {}
      applications_hash[application][:chemistry] = marks[application.id][0]
      applications_hash[application][:biology] = marks[application.id][1]
      applications_hash[application][:russian] = marks[application.id][2]
      applications_hash[application][:achievement] = achiev_apps.include?(application.id) ? 10 : 0
      applications_hash[application][:summa] = marks[application.id].sum
      applications_hash[application][:full_summa] = [applications_hash[application][:summa], applications_hash[application][:achievement]].sum
      applications_hash[application][:competitions] = app_competitions[application.id]
      applications_hash[application][:original_received] = true if application.original_received_date
      applications_hash[application][:enrolled] = nil
    end
    applications_hash = applications_hash.sort_by{|k, v| [v[:full_summa], v[:summa], v[:chemistry], v[:biology], v[:russian]]}.reverse
    
    admission_volume_hash = {}
    default_campaign.competitive_group_items.each do |av|
      admission_volume_hash[av.direction_id] = {}
      admission_volume_hash[av.direction_id][:number_budget_o] = av.number_budget_o
      admission_volume_hash[av.direction_id][:number_paid_o] = av.number_paid_o
      admission_volume_hash[av.direction_id][:number_target_o] = av.number_target_o
      admission_volume_hash[av.direction_id][:number_quota_o] = av.number_quota_o
    end
    target_competitions = {}
    target_competitions[438] = {}
    target_competitions[441] = {}
    target_competitions[470] = {}
    default_campaign.competitive_group_target_items.each do |i|
      target_competitions[i.direction_id][i.target_organization_id] = i.number_target_o
    end
    competitions = {}
    competitions[1] = admission_volume_hash[438][:number_budget_o]
    competitions[2] = admission_volume_hash[441][:number_budget_o]
    competitions[3] = admission_volume_hash[470][:number_budget_o]
    competitions[4] = admission_volume_hash[438][:number_paid_o]
    competitions[5] = admission_volume_hash[441][:number_paid_o]
    competitions[6] = admission_volume_hash[470][:number_paid_o]
    competitions[7] = target_competitions[438]
    competitions[8] = target_competitions[441]
    competitions[9] = target_competitions[470]
    competitions[10] = admission_volume_hash[438][:number_quota_o]
    competitions[11] = admission_volume_hash[441][:number_quota_o]
    competitions[12] = admission_volume_hash[470][:number_quota_o]
    trigger = 1
    while trigger == 1
      applications_hash.each do |k, v|
        (v[:competitions] - [v[:enrolled]]).reverse.each do |c|
          if (7..9).to_a.include?(c) 
            if competitions[c][k.target_organization_id] && competitions[c][k.target_organization_id] > 0
              competitions[c][k.target_organization_id] -= 1
              competitions[v[:enrolled]] +=1 if v[:enrolled]
              v[:enrolled] = c
            end
          else
            if competitions[c] > 0
              if v[:enrolled]
                (7..9).to_a.include?(v[:enrolled]) ? competitions[v[:enrolled]][k.target_organization_id] += 1 : competitions[v[:enrolled]] += 1 
              end
              competitions[c] -= 1
              v[:enrolled] = c
            end
          end
        end
      en = v[:competitions].index(v[:enrolled])
      v[:competitions].delete_if{|i| v[:competitions].index(i) > en} if v[:enrolled]
      end
      trigger = [competitions[10], competitions[11], competitions[12], competitions[7].values.sum, competitions[8].values.sum, competitions[9].values.sum].sum > 0 ? 1 : 0
      if trigger == 1
        competitions[1] += [competitions[10], competitions[7].values.sum].sum
        competitions[10] = 0
        competitions[7].each{|k, v| competitions[7][k] = 0}
        competitions[2] += [competitions[11], competitions[8].values.sum].sum
        competitions[11] = 0
        competitions[8].each{|k, v| competitions[8][k] = 0}
        competitions[3] += [competitions[12], competitions[9].values.sum].sum
        competitions[12] = 0
        competitions[9].each{|k, v| competitions[9][k] = 0}
      end
    end
    applications_hash
  end
  
  def self.competition_lists(default_campaign)
    applications = Application.select([:id, :application_number, :entrant_last_name, :entrant_first_name, :entrant_middle_name, :campaign_id, :original_received_date, :last_deny_day, :target_organization_id]).includes(:marks, :competitions).where(campaign_id: default_campaign, last_deny_day: nil).select{|a| a.marks.map(&:value).select{|m| m > 35}.count == 3}
    achiev_apps = Application.where(campaign_id: default_campaign).joins(:institution_achievements).map(&:id)
    marks = Mark.order(:entrance_test_item_id).joins(:application).where(applications: {campaign_id: default_campaign}).group_by(&:application_id).map{|a, ms| {a => ms.map{|m| m.value}}}.inject(:merge)
    competitions = Competition.order(:priority).joins(:application).where(applications: {campaign_id: default_campaign}).group_by(&:application_id).map{|a, cs| {a => cs.map{|c| c.competition_item_id}}}.inject(:merge)
    contract_competitions = Competition.order(:priority).joins(:application).where(contract: true, applications: {campaign_id: default_campaign}).group_by(&:application_id).map{|a, cs| {a => cs.map{|c| c.competition_item_id}}}.inject(:merge)
    admissed_competitions = Competition.order(:priority).joins(:application).where(applications: {campaign_id: default_campaign}).where.not(admission_date: nil).group_by(&:application_id).map{|a, cs| {a => cs.map{|c| c.competition_item_id}}}.inject(:merge) || []
    admissed_competitions.each do |a, acs|
      ac = acs.first
      cs = competitions[a]
      i = cs.index(ac)
      cs.delete_if{|c| cs.index(c) >= i} if i
    end
    applications_hash = {}
    applications.each do |application|
      applications_hash[application] = {}
      applications_hash[application][:chemistry] = marks[application.id][0]
      applications_hash[application][:biology] = marks[application.id][1]
      applications_hash[application][:russian] = marks[application.id][2]
      applications_hash[application][:achievement] = achiev_apps.include?(application.id) ? 10 : 0
      applications_hash[application][:summa] = marks[application.id].sum
      applications_hash[application][:full_summa] = [applications_hash[application][:summa], applications_hash[application][:achievement]].sum
      applications_hash[application][:competitions] = competitions[application.id]
      applications_hash[application][:original_received] = true if application.original_received_date
      applications_hash[application][:contracts] = contract_competitions[application.id] || []
    end
    @applications_hash = applications_hash.sort_by{|k, v| [v[:full_summa], v[:summa], v[:chemistry], v[:biology], v[:russian]]}.reverse
  end
end
