class CreateAttendanceFacade
  def self.run(attendance, user, populate_students)
    participants = ZoomService.past_participants_meeting_report(attendance.zoom_meeting_id)[:participants]
    attendance.turing_module.create_students_from_participants(participants) if populate_students
    meeting_details = ZoomService.meeting_details(attendance.zoom_meeting_id)
    meeting_start_time = meeting_details[:start_time]
    meeting_title = meeting_details[:topic]
    attendance.update(meeting_time: DateTime.parse(meeting_start_time))
    attendance.update(meeting_title: meeting_title)

    attendance.turing_module.students.each do |student|
      participants_with_matching_zoom_id = participants.find_all {|participant| participant[:id] == student.zoom_id}
      participant = participants_with_matching_zoom_id.first
      participant_join_time = participant ? Time.parse(participant[:join_time]) : nil
      status = convert_status(participant_join_time, Time.parse(meeting_start_time))
      StudentAttendance.create(status: status, join_time: participant_join_time, attendance: attendance, student: student)
      participants -= participants_with_matching_zoom_id
    end

    participants_with_join_time_status = attatch_status_to_participants(participants,meeting_start_time)
    attendance.create_visiting_students(participants_with_join_time_status)
  end

  def self.convert_status(join_time, meeting_start_time)
    return 'absent' if join_time == nil
    minutes_passed_start_time = (join_time - meeting_start_time)/60
    return 'absent' if minutes_passed_start_time >= 30
    return 'tardy' if 1 <= minutes_passed_start_time
    return 'present'
  end
  
  def self.attatch_status_to_participants(participants, meeting_start_time)
    participants.map do |participant|
      participant[:status] = convert_status(Time.parse(participant[:join_time]), Time.parse(meeting_start_time))
      participant
    end 
  end 
end
