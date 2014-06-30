class Competition < ActiveRecord::Base
  belongs_to :competition_item
  belongs_to :application
  
  def self.import_from_row(row, application)
    competition_items = CompetitionItem.all
    competitions = application.competitions
    competitions.each do |competition|
      competition.destroy
    end
    competition_items.each do |competition_item|
      competition = competitions.where(id: competition_item.id).first || competitions.new if row["c_#{competition_item.id}"]
      competition.update_attributes(competition_item_id: competition_item.id, priority: row["c_#{competition_item.id}"]) if row["c_#{competition_item.id}"]
    end
  end
end
