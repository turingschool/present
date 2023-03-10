class CreateAttendanceFacade
  attr_reader :meeting, :module, :attendance

  def self.take_attendance(meeting, turing_module, user)
    new(meeting, turing_module, user).run  
  end

  def initialize(meeting_id, turing_module, user)
    @meeting = Meeting.from_id(meeting_id)
    raise meeting.invalid_message unless meeting.valid?
    @module = turing_module
    @attendance = self.module.attendances.create(user: user)
  end

  def run
    meeting.create_child_attendance_record(attendance)
    take_participant_attendance
    take_absentee_attendance
    update_populi
    return attendance
  end

private
  def take_participant_attendance
    meeting.participants.each do |participant|
      student = attendance.find_student(participant)
      next if student.nil?
      student_attendance = attendance.student_attendances.find_or_create_by(student: student)
      student_attendance.assign_status(participant.join_time, populi_meeting.start)
    end
  end

  def take_absentee_attendance
    self.module.students.each do |student|
      unless attendance.student_attendances.find_by(student: student)
        student_attendance = attendance.student_attendances.create(student: student)
        student_attendance.assign_status(nil, populi_meeting.start)
      end
    end
  end

  def update_populi
    attendance.student_attendances.each do |student_attendance|
      populi_service.update_student_attendance(course_id, populi_meeting.id, student_attendance.student.populi_id, student_attendance.status)
    end
  end

  def populi_service
    @service ||= PopuliService.new
  end

  def course_id
    self.module.populi_course_id
  end

  def populi_meeting
    @populi_meeting ||= retrieve_populi_meeting
  end

  def retrieve_populi_meeting
    # REFACTOR: cache these meetings? update: memozing for now
    data = populi_service.course_meetings(course_id)[:response][:meeting].min_by do |data|
      (meeting.start_time.to_i - data[:start].to_datetime.to_i).abs
    end
    meeting = PopuliMeeting.new(data)
  end
end
