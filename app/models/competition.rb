class Competition < ActiveRecord::Base
  belongs_to :competition_item
  belongs_to :application
  
  def self.import_from_row(row, application)
    competitions = application.competitions
    competition_items = CompetitionItem.order(:id)
    competition_items.each do |competition_item|
      competition = competitions.find_by_competition_item_id(row[competition_item.id]) || competitions.new
      competition.create(competition_item_id: competition_item.id, priority: row.to_hash.slice(*competition_item)) if row.to_hash.slice(*competition_item)
    end
  end
end
