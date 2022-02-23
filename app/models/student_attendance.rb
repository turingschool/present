class StudentAttendance < ApplicationRecord
  belongs_to :student
  belongs_to :attendance

  enum status: [:present, :tardy, :absent]
end
