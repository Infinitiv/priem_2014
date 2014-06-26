class IdentityDocument < ActiveRecord::Base
  belongs_to :type
  belongs_to :application
  
    def self.import_from_row(row, application)
    accessible_attributes = column_names
    identity_documents = application.identity_documents
    identity_document = identity_documents.where(identity_document_series: row["identity_document_series"], identity_document_number: row["identity_document_number"]).first || identity_documents.new
    identity_document.attributes = row.to_hash.slice(*accessible_attributes)
    identity_document.save!
  end
end
