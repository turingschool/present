class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user
  has_one :slack_attendance
  has_one :zoom_attendance
  has_many :zoom_aliases, through: :zoom_attendance
  has_many :student_attendances, dependent: :destroy
  has_many :students, through: :student_attendances

  def find_student_from_participant(participant)
    if participant.class == ZoomParticipant
      zoom_alias = zoom_attendance.find_or_create_zoom_alias(participant.name)
      return zoom_alias.student if zoom_alias
    elsif participant.class == SlackThreadParticipant
      Student.find_by(slack_id: participant.id)
    end
  end

  def record(meeting, attendance_time)
    meeting.create_child_attendance_record(self)
    meeting.participants.each do |participant|
      student = find_student_from_participant(participant)
      next if student.nil?
      student_attendances.new(student: student, status: participant.status)
    end
    student_ids = student_attendances.map(&:student_id)
    absent_students = turing_module.students.where.not(id: student_ids)
    absent_students.each do |student|
      student_attendances.new(student: student, status: "absent")
    end
    self.transaction do
      student_attendances.each(&:save!)
    end
  end
end
