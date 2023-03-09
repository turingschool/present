class ZoomParticipant < Participant
  attr_reader :name

  def self.from_meeting(meeting_participant)
    new(meeting_participant[:id], meeting_participant[:join_time], meeting_participant[:name])
  end

  def find_student
    Student.find_by(zoom_id: self.id)
  end

  def initialize(id, join_time, name)
    super(id, join_time)
    @name = name  
  end
end