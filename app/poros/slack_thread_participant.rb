class SlackThreadParticipant
  attr_reader :join_time, :status, :slack_id
  
  def initialize(join_time, status, slack_id)
    @join_time = join_time
    @status = status
    @slack_id = slack_id
  end
end