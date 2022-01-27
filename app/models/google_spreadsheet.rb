class GoogleSpreadsheet < ApplicationRecord
  has_many :google_sheets

  validates_presence_of :google_id
end
