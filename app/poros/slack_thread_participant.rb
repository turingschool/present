class SlackThreadParticipant < Participant
  # attr_reader :join_time, :status, :slack_id
  
  # def initialize(join_time, status, slack_id)
  #   super(join_time, status)
  #   @status = status
  #   @slack_id = slack_id
  # end
  def id_column_name
    :slack_id
  end
end