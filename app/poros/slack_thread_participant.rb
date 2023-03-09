class SlackThreadParticipant < Participant
  def find_student
    Student.find_by(slack_id: self.id)
  end
end