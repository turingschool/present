class SlackThreadParticipant < Participant
  def id_column_name
    :slack_id
  end
end