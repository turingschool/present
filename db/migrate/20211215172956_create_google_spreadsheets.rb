class CreateGoogleSpreadsheets < ActiveRecord::Migration[5.2]
  def change
    create_table :google_spreadsheets do |t|
      t.string :google_id
    end
  end
end
