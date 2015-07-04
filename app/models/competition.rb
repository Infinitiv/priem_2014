#encoding: utf-8
class Competition < ActiveRecord::Base
  belongs_to :competition_item
  belongs_to :application
  has_many :marks, through: :application
  has_one :competitive_group, through: :competition_item
  
  def self.import_from_row(row, application)
    competition_items = application.campaign.competition_items
    competitions = application.competitions
    competitions.each do |competition|
      competition.destroy
    end
    competition_items.each do |competition_item|
      competition = competitions.where(id: competition_item.id).first || competitions.new if row[competition_item.code.to_s]
      competition.update_attributes(competition_item_id: competition_item.id, priority: row[competition_item.code.to_s].to_i) if row[competition_item.code.to_s]
    end
  end
  
  def rank
    campaign_id = application.campaign_id
    summa = application.summa + application.achiev_summa
    applications = Application.where(campaign_id: campaign_id).joins(:institution_achievements).map(&:id)
    "(место в конкурсе - #{rank_all(campaign_id, summa, applications)}, с учетом оригиналов - #{rank_original_only(campaign_id, summa, applications)})"
  end
  
  def rank_target
    campaign_id = application.campaign_id
    target_organization_id = application.target_organization_id
    summa = application.summa + application.achiev_summa
    applications = Application.where(campaign_id: campaign_id).joins(:institution_achievements).map(&:id)
    marks = Mark.joins(:competitions).where(competitions: {competition_item_id: competition_item_id}, applications: {campaign_id: campaign_id, target_organization_id: target_organization_id}).where.not(applications: {original_received_date: nil}).group_by(&:application_id).map{|a, ms| applications.include?(a) ? ms.map{|m| m.value}.sum + 10 : ms.map{|m| m.value}.sum}.sort.reverse
    marks_count = marks.count{|x| x == summa}
    marks_count > 1 ? "место в конкурсе - #{marks.index(summa) + 1}-#{marks.index(summa) + 1 + marks_count}" : "место в конкурсе #{marks.index(summa) + 1}"
  end
  
  def rank_all(campaign_id, summa, applications)
    marks = Mark.joins(:competitions).where(competitions: {competition_item_id: competition_item_id}, applications: {campaign_id: campaign_id}).group_by(&:application_id).map{|a, ms| applications.include?(a) ? ms.map{|m| m.value}.sum + 10 : ms.map{|m| m.value}.sum}.sort.reverse
    marks_count = marks.count{|x| x == summa}
    marks_count > 1 ? "#{marks.index(summa) + 1}-#{marks.index(summa) + 1 + marks_count}" : marks.index(summa) + 1
  end
  
  def rank_original_only(campaign_id, summa, applications)
    marks = Mark.joins(:competitions).where(competitions: {competition_item_id: competition_item_id}, applications: {campaign_id: campaign_id}).where.not(applications: {original_received_date: nil}).group_by(&:application_id).map{|a, ms| applications.include?(a) ? ms.map{|m| m.value}.sum + 10 : ms.map{|m| m.value}.sum}.sort.reverse
    marks_count = marks.count{|x| x == summa}
    marks_count > 1 ? "#{marks.index(summa) + 1}-#{marks.index(summa) + 1 + marks_count}" : marks.index(summa) + 1
  end
end
