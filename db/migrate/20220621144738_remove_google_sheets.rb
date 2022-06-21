class RemoveGoogleSheets < ActiveRecord::Migration[5.2]
  def change
    drop_table :google_sheets
    drop_table :google_spreadsheets
  end
end
