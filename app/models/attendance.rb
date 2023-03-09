class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user

  has_one :slack_attendance
  has_one :zoom_attendance

  has_many :zoom_aliases, through: :zoom_attendance
  
  has_many :student_attendances, dependent: :destroy

  has_many :students, through: :student_attendances

  def find_student(participant)
    if participant.class == ZoomParticipant
      zoom_attendance.find_student_from_zoom_participant(participant)
    elsif participant.class == SlackThreadParticipant
      Student.find_by(slack_id: participant.id)
    end
  end
end
