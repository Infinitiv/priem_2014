class CreateJoinTableInstitutionAchievementApplication < ActiveRecord::Migration
  def change
    create_join_table :institution_achievements, :applications do |t|
      # t.index [:_id, :_id]
      # t.index [:_id, :_id]
    end
  end
end
