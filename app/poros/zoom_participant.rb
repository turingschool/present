class ZoomParticipant < Participant
  def self.from_meeting(meeting_participant)
    join_time = Time.parse(meeting_participant[:join_time])
    new(nil, meeting_participant[:name], join_time, nil)
  end

  def assign_status(attendance_time)
    return unless attendance_time
    minutes_passed_start_time = (join_time - attendance_time)/60.0
    if minutes_passed_start_time > 30
      @status = 'absent' 
    elsif minutes_passed_start_time > 1
      @status = 'tardy'
    else
      @status = 'present' 
    end
  end
end