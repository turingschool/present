class Attendance < ApplicationRecord
  belongs_to :turing_module

  has_one :slack_attendance
  has_one :zoom_attendance
  
  has_many :student_attendances, dependent: :destroy

  has_many :students, through: :student_attendances

  def find_status_for_student(student)
    student_attendances.find do |student_attendance|
      student_attendance.student.id == student.id
    end.status
  end
end
