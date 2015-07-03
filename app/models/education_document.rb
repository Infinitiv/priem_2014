#encoding: utf-8
class EducationDocument < ActiveRecord::Base
  belongs_to :education_document_type
  belongs_to :application
  
  def self.import_from_row(row, application)
    accessible_attributes = column_names
    education_document = application.education_document || new
    education_document.attributes = row.to_hash.slice(*accessible_attributes)
    education_document.application_id = application.id
    education_document.save!
  end

  def education_document_data
    "Серия #{education_document_series} номер #{education_document_number}, выдан #{education_document_date}"
  end
end
