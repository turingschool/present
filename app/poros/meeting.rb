class Meeting
  attr_reader :id, :start_time
  
  def initialize(id, start_time)
    @id = id  
    @start_time = start_time  
  end 

  def self.from_id(id)
    if id.include? 'slack'
      SlackThread.from_message_link(id)
    else
      ZoomMeeting.from_meeting_details(id)
    end
  end
end