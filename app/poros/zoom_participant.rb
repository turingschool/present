class ZoomParticipant < Participant
  attr_reader :name

  def self.from_meeting(meeting_participant)
    new(meeting_participant[:name], meeting_participant[:join_time])
  end

  def find_student
    Student.find_by(zoom_id: self.id)
  end
end