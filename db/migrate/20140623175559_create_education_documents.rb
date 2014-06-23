class CreateEducationDocuments < ActiveRecord::Migration
  def change
    create_table :education_documents do |t|
      t.references :education_document_type, index: true
      t.string :series
      t.string :number
      t.date :date

      t.timestamps
    end
  end
end
