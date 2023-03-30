class ZoomParticipant < Participant

  def initialize(participant_data)
    @join_time = Time.parse(participant_data[:join_time])
    @name = participant_data[:name]
  end

  def attendance_status(attendance_time)
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