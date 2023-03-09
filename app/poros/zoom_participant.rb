class ZoomParticipant < Participant
  attr_reader :name

  def self.from_meeting(meeting_participant)
    new(meeting_participant[:name], meeting_participant[:join_time])
  end

  
end