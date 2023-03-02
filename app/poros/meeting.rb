class Meeting
  attr_reader :id, :start_time
  
  def initialize(id, start_time)
    # Abstract Class
    raise 'Abstract class Meeting cannot be instantiated' if self.class == Meeting
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

# Interfaces
  @@interfaces = :create_child_attendance_record, :participants, :valid?, :invalid_message
  
  @@interfaces.each do |interface|
    define_method(interface) do |*args|
      raise NoMethodError.new("#{self.class} does not implement required method: #{interface}")
    end
  end
end