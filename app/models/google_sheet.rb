class GoogleSheet < ApplicationRecord
  belongs_to :turing_module
  belongs_to :google_spreadsheet

  validates_presence_of :google_id, :name
end
