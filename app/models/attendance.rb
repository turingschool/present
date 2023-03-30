class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user
  belongs_to :meeting, polymorphic: true
  has_many :zoom_aliases, through: :zoom_attendance
  has_many :student_attendances, dependent: :destroy
  has_many :students, through: :student_attendances

  validates_presence_of :attendance_time

  def child
    return slack_attendance if slack_attendance
    return zoom_attendance if zoom_attendance
  end

  def record
    self.transaction do
      # meeting.assign_participant_statuses(attendance_time)
      take_participant_attendance
      take_absentee_attendance
    end
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
      # REFACTOR: Should the participant determine its status? Or the meeting?
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
  
  def pretty_date
    attendance_time.in_time_zone('Mountain Time (US & Canada)').strftime("%A %b %e, %Y")
  end

  def pretty_time 
    attendance_time.in_time_zone('Mountain Time (US & Canada)').strftime('%l:%M %p').strip
  end 
end
