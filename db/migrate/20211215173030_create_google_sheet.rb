class CreateGoogleSheet < ActiveRecord::Migration[5.2]
  def change
    create_table :google_sheets do |t|
      t.references :google_spreadsheet, foreign_key: true
      t.references :turing_module, foreign_key: true
      t.string :name
      t.string :google_id
    end
  end
end
