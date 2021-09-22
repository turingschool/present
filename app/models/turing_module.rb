class TuringModule < ApplicationRecord
  belongs_to :inning
  has_many :attendances

  validates_presence_of :name, :google_spreadsheet_id, :google_sheet_name
end
