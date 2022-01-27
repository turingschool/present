class TuringModule < ApplicationRecord
  belongs_to :inning
  has_many :attendances

  validates_presence_of :google_spreadsheet_id, :program
  validates_numericality_of :module_number, {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 4,
    only_integer: true
  }

  validates_inclusion_of :calendar_integration, in: [true, false]

  enum program: [:FE, :BE, :Combined]

  def name
    "#{self.program} Mod #{self.module_number}"
  end
end
