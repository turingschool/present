class ZoomParticipant
  attr_reader :status, :join_time, :name
  attr_accessor :duration

  ZOOM_TARDY_GRACE_PERIOD_IN_MINUTES = 1
  ZOOM_ABSENT_GRACE_PERIOD_IN_MINUTES = 30

  def initialize(participant_data)
    @join_time = Time.parse(participant_data[:join_time])
    @name = participant_data[:name]
    @status = participant_data[:attendance_status]
    @duration = participant_data[:duration]
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
end