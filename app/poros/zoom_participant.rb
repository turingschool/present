class ZoomParticipant
  attr_reader :status, :join_time, :leave_time, :name
  attr_accessor :duration

  ZOOM_TARDY_GRACE_PERIOD_IN_MINUTES = 1
  ZOOM_ABSENT_GRACE_PERIOD_IN_MINUTES = 30

  def initialize(participant_data, meeting_start, meeting_end)
    @join_time = Time.parse(participant_data[:join_time])
    @leave_time = Time.parse(participant_data[:leave_time])
    @name = participant_data[:name]
    @status = participant_data[:attendance_status]
    @duration = participant_data[:duration]
    update_duration(meeting_start, meeting_end)
  end

  def assign_status!(attendance_time)
    minutes_passed_start_time = (join_time - attendance_time)/60.0
    if minutes_passed_start_time > ZOOM_ABSENT_GRACE_PERIOD_IN_MINUTES
      @status = 'absent' 
    elsif minutes_passed_start_time > ZOOM_TARDY_GRACE_PERIOD_IN_MINUTES
      @status = 'tardy'
    else
      @status = 'present' 
    end
  end

private
  def update_duration(meeting_time, meeting_end)
    if @join_time < meeting_time
      seconds_before_meeting_time = meeting_time - @join_time
      @duration -= seconds_before_meeting_time
    end
    if @leave_time > meeting_end
      seconds_after_meeting_time = @leave_time - meeting_end
      @duration -= seconds_after_meeting_time
    end
  end
end