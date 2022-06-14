class RemoveSheetAttributesFromModules < ActiveRecord::Migration[5.2]
  def change
    remove_column :turing_modules, :google_spreadsheet_id
    remove_column :turing_modules, :google_sheet_name
  end
end
