class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user
  has_one :slack_attendance
  has_one :zoom_attendance
  has_many :zoom_aliases, through: :zoom_attendance
  has_many :student_attendances, dependent: :destroy
  has_many :students, through: :student_attendances

  def record(meeting, attendance_time)
    self.transaction do
      meeting.create_child_attendance_record(self)
      student_attendances = take_participant_attendance(meeting.participants)
      take_absentee_attendance
    end
  end

  def take_participant_attendance(participants)
    participants.each do |participant|
      student = find_student_from_participant(participant)
      next if student.nil?
      student_attendances.create(student: student, status: participant.status)
    end
  end

  def take_absentee_attendance
    student_ids = student_attendances.pluck(:student_id)
    absent_students = turing_module.students.where.not(id: student_ids)
    absent_students.each do |student|
      student_attendances.create(student: student, status: "absent")
    end
  end

  def find_student_from_participant(participant)
    if participant.class == ZoomParticipant
      zoom_alias = zoom_attendance.find_or_create_zoom_alias(participant.name)
      return zoom_alias.student if zoom_alias
    elsif participant.class == SlackThreadParticipant
      Student.find_by(slack_id: participant.id)
    end
  end
end
