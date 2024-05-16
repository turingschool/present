class CreateAttendanceFacade
  def self.take_attendance(meeting_url, turing_module, user)
    begin
      ActiveRecord::Base.transaction do
        meeting = create_meeting(meeting_url)
        check_or_create_populi_course_meeting(meeting, turing_module)
        populi_meeting = meeting.closest_populi_meeting_to_start_time(turing_module.populi_course_id)
        attendance = turing_module.attendances.find_or_initialize_by(attendance_time: populi_meeting.start_at, end_time: populi_meeting.end_at, meeting: meeting)
        attendance.update(user: user)
        attendance.record
        attendance
      end
    rescue NoMethodError 
      return InvalidMeetingError.new("Populi meeting was not created successfully.")
    end
  end

  def self.create_meeting(meeting_url)
    if meeting_url.downcase.include? 'slack'
      @meeting = SlackThread.from_message_link(meeting_url)
    else
      @meeting = ZoomMeeting.from_meeting_details(meeting_url)
    end
  end

  def self.check_or_create_populi_course_meeting(meeting, turing_module)
    service = PopuliService.new
    course_offering_id = turing_module.populi_course_id
    course_meetings = service.course_meetings(course_offering_id)
    slack_or_zoom_meeting_start_time = meeting.start_time.to_time.utc
    if course_meetings[:data].any? { |course_meeting| course_meeting[:start_at].to_time.utc == slack_or_zoom_meeting_start_time }
      return "Meeting already exists in Populi."
    else
      enrollment_id = service.enrollments(course_offering_id)[:data].first[:id]
      return service.create_student_attendance(course_offering_id, enrollment_id, slack_or_zoom_meeting_start_time)
    end
  end
end
