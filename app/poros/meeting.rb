class Meeting
  # Abstract Class
  def new
    raise 'Abstract class Meeting cannot be instantiated'
  end

  attr_reader :id, :start_time
  
  def initialize(id, start_time)
    @id = id  
    @start_time = start_time  
  end

# Interfaces
  def create_child_attendance_record
    raise NoMethodError.new("#{self.class} does not implement required method: create_child_attendance_record")
  end

  def participants
    raise NoMethodError.new("#{self.class} does not implement required method: participants")
  end
end