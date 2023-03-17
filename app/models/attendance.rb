class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user
  has_one :slack_attendance, dependent: :destroy
  has_one :zoom_attendance, dependent: :destroy
  has_many :zoom_aliases, through: :zoom_attendance
  has_many :student_attendances, dependent: :destroy
  has_many :students, through: :student_attendances

  validates_presence_of :attendance_time

  def child
    return slack_attendance if slack_attendance
    return zoom_attendance if zoom_attendance
  end

  def record(meeting)
    self.transaction do
      create_child_attendance_record(meeting)
      meeting.assign_participant_statuses(attendance_time)
      student_attendances = take_participant_attendance(meeting.participants)
      take_absentee_attendance
    end
  end
  
  def create_child_attendance_record(meeting)
    if meeting.respond_to? :message_timestamp
      SlackAttendance.create(channel_id: meeting.channel_id, sent_timestamp: meeting.message_timestamp, attendance_start_time: attendance_time, attendance: self)
    elsif meeting.respond_to? :title
      ZoomAttendance.create!(meeting_time: meeting.start_time, meeting_title: meeting.title, zoom_meeting_id: meeting.id, attendance: self)
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

  def retake_zoom_attendance
    self.student_attendances.destroy_all
    meeting = ZoomMeeting.from_meeting_details(zoom_attendance.zoom_meeting_id)
    self.record(meeting)
  end

  def pretty_attendance_time
    attendance_time.in_time_zone('Mountain Time (US & Canada)').strftime("%l:%M%P - %b %e, %Y")
  end
end
