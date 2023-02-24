class ZoomParticipant
  attr_reader :name, :id, :join_time

  def self.from_meeting(meeting_participant)
    new(meeting_participant[:name], meeting_participant[:id], meeting_participant[:join_time])
  end

  def initialize(name, id, join_time = nil)
    @name = name
    @id = id
    @join_time = join_time
  end
end