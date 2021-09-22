class CreateTuringModules < ActiveRecord::Migration[5.2]
  def change
    create_table :turing_modules do |t|
      t.string :name
      t.references :inning, foreign_key: true
      t.string :google_spreadsheet_id
      t.string :google_sheet_name

      t.timestamps
    end
  end
end
