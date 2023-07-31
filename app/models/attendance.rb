class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user
  belongs_to :meeting, polymorphic: true
  has_many :student_attendances, dependent: :destroy
  has_many :students, through: :student_attendances

  validates_presence_of :attendance_time

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
      if student_attendance.record_status_for_participant!(participant)
        meeting.connect_alias(student_attendance, participant.name) if meeting.respond_to? :zoom_aliases
      end
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
    hour, minutes = time.split(":").map(&:to_i)
    
    if !validate_time_input(hour, minutes)
      new_time = attendance_time.in_time_zone('Mountain Time (US & Canada)').change(hour: hour, min: minutes)
      self.update!(attendance_time: new_time)
    end
  end
  
  def validate_time_input(hour, minutes)
    if hour < 0 || hour > 23 || minutes < 0 || minutes > 59
      raise ArgumentError, "Invalid time format. Hour and minutes should be in the range 00:00 to 23:59."
    end
  end

  def count_status(status)
    student_attendances.where(status: status).count
  end

  def transfer_to_populi!(populi_meeting_id)
    service = PopuliService.new
    course_id = self.turing_module.populi_course_id
    student_attendances.includes(:student).each do |student_attendance|
      response = service.update_student_attendance(course_id, populi_meeting_id, student_attendance.student.populi_id, student_attendance.status)
      Rails.logger.info "Update Attendance Response: #{response.to_s}"
      begin
        raise AttendanceUpdateError.new("UPDATE FAILED") unless response[:response][:result] == "UPDATED"
      rescue AttendanceUpdateError, NoMethodError
        Honeybadger.notify("UPDATE FAILED. Student: #{student_attendance.student.populi_id}, status: #{student_attendance.status}, response: #{response.to_s}")
      end
    end
  end
end
