class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user
  belongs_to :meeting, polymorphic: true
  has_many :student_attendances, dependent: :destroy
  has_many :students, through: :student_attendances

  validates_presence_of :attendance_time

  def child
    return slack_attendance if slack_attendance
    return zoom_attendance if zoom_attendance
  end

  def record
    take_participant_attendance
    take_absentee_attendance
  end

  def rerecord
    student_attendances.destroy_all
    record
  end

  def take_participant_attendance
    meeting.participants.each do |participant|
      student = meeting.find_student_from_participant(participant)
      next if student.nil?
      student_attendance = student_attendances.find_or_create_by(student: student)
      participant.assign_status!(attendance_time)
      student_attendance.record_status_for_participant(participant)
    end
  end

  def take_absentee_attendance
    student_ids = student_attendances.pluck(:student_id)
    absent_students = turing_module.students.where.not(id: student_ids)
    absent_students.each do |student|
      student_attendances.create(student: student, status: "absent")
    end
  end

  def update_time(time)
    hour = time.split(":").first
    minutes = time.split(":").last
    new_time = attendance_time.in_time_zone('Mountain Time (US & Canada)').change(hour: hour, min: minutes)
    self.update!(attendance_time: new_time)
  end

  def count_status(status)
    student_attendances.where(status: status).count
  end

  def transfer_to_populi!
    service = PopuliService.new
    course_id = self.turing_module.populi_course_id
    populi_meeting = meeting.closest_populi_meeting_to_start_time(course_id)
    student_attendances.includes(:student).each do |student_attendance|
      service.update_student_attendance(course_id, populi_meeting.id, student_attendance.student.populi_id, student_attendance.status)
    end
  end
end
