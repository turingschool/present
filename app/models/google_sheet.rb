class GoogleSheet < ApplicationRecord
  belongs_to :turing_module
  belongs_to :google_spreadsheet

  validates_presence_of :google_id, :name

  def link
    "https://docs.google.com/spreadsheets/d/#{self.google_spreadsheet.google_id}#gid=#{self.google_id}"
  end
end
