class CreateAttendanceFacade
  def self.take_attendance(meeting_id, turing_module, user)
    course_id = turing_module.populi_course_id
    meeting = create_meeting(meeting_id)
    populi_meeting = retrieve_populi_meeting(course_id, meeting.start_time)
    meeting.assign_participant_statuses(populi_meeting.start)
    attendance = turing_module.attendances.create(user: user)
    attendance.record(meeting, populi_meeting.start)
    update_populi(attendance, course_id, populi_meeting.id)
    return attendance
  end

  def self.create_meeting(meeting_id)
    if meeting_id.downcase.include? 'slack'
      @meeting = SlackThread.from_message_link(meeting_id)
    else
      @meeting = ZoomMeeting.from_meeting_details(meeting_id)
    end
  end

  def self.update_populi(attendance, course_id, populi_meeting_id)
    attendance.student_attendances.each do |student_attendance|
      PopuliService.new.update_student_attendance(course_id, populi_meeting_id, student_attendance.student.populi_id, student_attendance.status)
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
