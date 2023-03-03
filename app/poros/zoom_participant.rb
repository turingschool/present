class ZoomParticipant < Participant
  attr_reader :name

  def self.from_meeting(meeting_participant)
    # new(meeting_participant[:id], meeting_participant[:join_time], meeting_participant[:name])
    new(meeting_participant[:id], meeting_participant[:join_time], meeting_participant[:name])
  end

  def initialize(id, join_time, name)
    super(id, join_time)
    @name = name  
  end

  def id_column_name
    :zoom_id
  end
end