class SlackThreadParticipant
  attr_reader :slack_id

  SLACK_TARDY_GRACE_PERIOD_IN_MINUTES = 5
  SLACK_ABSENT_GRACE_PERIOD_IN_MINUTES = 30

  def initialize(reply_info)
    @slack_id = reply_info[:slack_id]
    @reply_time = Time.parse(reply_info[:reply_timestamp])
  end

  def student
    Student.find_by(slack_id: slack_id)
  end

  def attendance_status(attendance_time)
    minutes_passed_start_time = (@reply_time - attendance_time)/60.0
    if minutes_passed_start_time > SLACK_ABSENT_GRACE_PERIOD_IN_MINUTES
      return 'absent' 
    elsif minutes_passed_start_time > SLACK_TARDY_GRACE_PERIOD_IN_MINUTES
      return 'tardy'
    else
      return 'present' 
    end
  end
end