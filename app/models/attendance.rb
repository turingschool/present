class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user

  has_one :slack_attendance
  has_one :zoom_attendance
  
  has_many :student_attendances, dependent: :destroy

  has_many :students, through: :student_attendances
end
