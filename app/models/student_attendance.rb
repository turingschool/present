class StudentAttendance < ApplicationRecord
  belongs_to :student
  belongs_to :attendance
end
