class ZoomParticipant < Participant
  def self.from_meeting(meeting_participant, attendance_time)
    join_time = Time.parse(meeting_participant[:join_time])
    status = attendance_status(join_time, attendance_time)
    new(nil, meeting_participant[:name], join_time, status)
  end

  def self.attendance_status(join_time, attendance_time)
    return nil unless attendance_time
    minutes_passed_start_time = (join_time - attendance_time)/60.0
    if minutes_passed_start_time > 30
      return 'absent' 
    elsif minutes_passed_start_time > 1
      return 'tardy'
    else
      return 'present' 
    end
  end
end