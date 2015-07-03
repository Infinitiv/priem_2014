class Mark < ActiveRecord::Base
  belongs_to :entrance_test_item
  
  def self.import_from_row(row, application)
    accessible_attributes = ['chemistry', 'biology', 'russian', 'chemistry_form', 'biology_form', 'russian_form']
    marks = application.marks
    entrance_test_items = application.entrance_test_items
    row_marks = row.to_hash.slice(*accessible_attributes)
    chemistry = marks.joins(:entrance_test_item).where(entrance_test_items: {subject_id: 11}).first || application.marks.new
    chemistry.entrance_test_item_id = entrance_test_items.find_by_subject_id(11).id
    chemistry.value = row_marks['chemistry'].to_i
    chemistry.form = row_marks['chemistry_form']
    chemistry.save!          
    biology = marks.joins(:entrance_test_item).where(entrance_test_items: {subject_id: 4}).first || application.marks.new
    biology.entrance_test_item_id = entrance_test_items.find_by_subject_id(4).id
    biology.value = row_marks['biology'].to_i
    biology.form = row_marks['biology_form']
    biology.save!
    russian = marks.joins(:entrance_test_item).where(entrance_test_items: {subject_id: 1}).first || application.marks.new
    russian.entrance_test_item_id = entrance_test_items.find_by_subject_id(1).id
    russian.value = row_marks['russian'].to_i
    russian.form = row_marks['russian_form']
    russian.save! 
  end
end
