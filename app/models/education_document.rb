class EducationDocument < ActiveRecord::Base
  belongs_to :education_document_type
  belongs_to :application
  
  def self.import_from_row(row, application)
    accessible_attributes = column_names
    education_documents = application.education_documents
    education_document = education_documents.where(education_document_series: row["education_document_series"], education_document_number: row["education_document_number"]).first || education_documents.new
    education_document.attributes = row.to_hash.slice(*accessible_attributes)
    education_document.save!
  end
end
