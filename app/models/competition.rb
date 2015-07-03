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
    marks = Competition.joins(:application).includes(:marks).where(competition_item_id: competition_item_id, applications: {campaign_id: application.campaign_id}).map{|c| c.marks.sum(:value)}.sort.reverse
    marks_count = marks.count{|x| x == application.summa}
    marks_count > 1 ? "#{marks.index(application.summa) + 1}-#{marks.index(application.summa) + 1 + marks_count}" : marks.index(application.summa) + 1
  end
end
