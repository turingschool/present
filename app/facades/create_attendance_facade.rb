class CreateAttendanceFacade
  def self.take_attendance(meeting_url, turing_module, user)
    course_id = turing_module.populi_course_id
    meeting = create_meeting(meeting_url)
    populi_meeting = retrieve_populi_meeting(course_id, meeting.start_time)
    attendance = turing_module.attendances.find_or_create_by(user: user, attendance_time: populi_meeting.start, meeting: meeting, populi_meeting_id: populi_meeting.id)
    attendance.record
    return attendance
  end

  def self.retake_attendance(attendance)
    attendance.student_attendances.destroy_all
    meeting = create_meeting(attendance.zoom_attendance.zoom_meeting_id)
    attendance.record(meeting)
    # update_populi(attendance, course_id, populi_meeting.id)
  end

  def self.create_meeting(meeting_url)
    if meeting_url.downcase.include? 'slack'
      @meeting = SlackThread.from_message_link(meeting_url)
    else
      @meeting = ZoomMeeting.from_meeting_details(meeting_url)
    end
  end

  def self.retrieve_populi_meeting(course_id, start_time)
    # REFACTOR: cache these meetings? update: memozing for now
    data = PopuliService.new.course_meetings(course_id)[:response][:meeting].min_by do |data|
      (start_time.to_i - data[:start].to_datetime.to_i).abs
    end
    meeting = PopuliMeeting.new(data)
  end
end
