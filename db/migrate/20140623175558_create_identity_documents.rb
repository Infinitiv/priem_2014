class CreateIdentityDocuments < ActiveRecord::Migration
  def change
    create_table :identity_documents do |t|
      t.references :identity_document_type, index: true
      t.string :series
      t.string :number
      t.date :date

      t.timestamps
    end
  end
end
