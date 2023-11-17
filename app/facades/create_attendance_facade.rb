class CreateAttendanceFacade
  def self.take_attendance(meeting_url, turing_module, user)
    meeting = create_meeting(meeting_url)
    populi_meeting = meeting.closest_populi_meeting_to_start_time(turing_module.populi_course_id)
    attendance = turing_module.attendances.find_or_initialize_by(attendance_time: populi_meeting.start, end_time: populi_meeting.end, meeting: meeting)
    attendance.update(user: user)
    attendance.record
    return attendance
  end

  def self.create_meeting(meeting_url)
    if meeting_url.downcase.include? 'slack'
      @meeting = SlackThread.from_message_link(meeting_url)
    else
      @meeting = ZoomMeeting.from_meeting_details(meeting_url)
    end
  end
end
