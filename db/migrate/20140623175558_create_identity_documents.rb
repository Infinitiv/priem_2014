class CreateIdentityDocuments < ActiveRecord::Migration
  def change
    create_table :identity_documents do |t|
      t.references :application, index: true
      t.references :identity_document_type, index: true
      t.string :identity_document_series
      t.string :identity_document_number
      t.date :identity_document_date

      t.timestamps
    end
  end
end
