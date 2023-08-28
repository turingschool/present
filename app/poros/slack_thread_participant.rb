class SlackThreadParticipant
  attr_reader :slack_id, :status, :join_time

  SLACK_TARDY_GRACE_PERIOD_IN_MINUTES = 5
  SLACK_ABSENT_GRACE_PERIOD_IN_MINUTES = 30

  def initialize(reply_info)
    @slack_id = reply_info[:slack_id]
    @join_time = Time.parse(reply_info[:reply_timestamp])
  end

  def assign_status!(attendance_time)
    minutes_passed_start_time = (join_time - attendance_time)/60.0
    if minutes_passed_start_time > SLACK_ABSENT_GRACE_PERIOD_IN_MINUTES
      @status = 'absent' 
    elsif minutes_passed_start_time > SLACK_TARDY_GRACE_PERIOD_IN_MINUTES
      @status = 'tardy'
    else
      @status = 'present' 
    end
  end

  def duration
    nil
  end
end