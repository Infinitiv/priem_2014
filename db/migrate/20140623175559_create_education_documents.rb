class CreateEducationDocuments < ActiveRecord::Migration
  def change
    create_table :education_documents do |t|
      t.references :application, index: true
      t.references :education_document_type, index: true
      t.string :education_document_series
      t.string :education_document_number
      t.date :education_document_date

      t.timestamps
    end
  end
end
