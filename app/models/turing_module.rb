class TuringModule < ApplicationRecord
  belongs_to :inning
  has_many :attendances
  has_one :google_sheet
  has_many :students

  validates_numericality_of :module_number, {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 4,
    only_integer: true
  }

  validates_inclusion_of :calendar_integration, in: [true, false]

  validates_presence_of :program
  enum program: [:FE, :BE, :Combined]

  def name
    "#{self.program} Mod #{self.module_number}"
  end
end
