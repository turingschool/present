class TuringModule < ApplicationRecord
  belongs_to :inning

  validates_presence_of :name, :google_spreadsheet_id, :google_sheet_name
end
