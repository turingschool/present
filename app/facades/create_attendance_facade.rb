class CreateAttendanceFacade
  attr_reader :meeting, :module, :attendance

  def self.take_attendance(meeting, turing_module, user)
    new(meeting, turing_module, user).run  
  end

  def initialize(meeting_id, turing_module, user)
    @module = turing_module
    @attendance = self.module.attendances.create(user: user)
    create_meeting(meeting_id)
  end

  def create_meeting(meeting_id)
    if meeting_id.downcase.include? 'slack'
      @meeting = SlackThread.from_message_link(meeting_id)
    else
      @meeting = ZoomMeeting.from_meeting_details(meeting_id)
      @meeting.attendance_time = populi_meeting.start
    end
  end

  def run
    attendance.record(meeting, populi_meeting.start)
    update_populi
    return attendance
  end

private
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
