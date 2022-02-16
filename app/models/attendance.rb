class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user
  has_many :student_attendances
  has_many :students, through: :student_attendances

  validates_presence_of :zoom_meeting_id
  validates_uniqueness_of :zoom_meeting_id
end
