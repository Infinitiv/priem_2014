class CreateEducationDocumentTypes < ActiveRecord::Migration
  def change
    create_table :education_document_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
