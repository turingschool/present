class Meeting
  attr_reader :id, :start_time
  
  def initialize(id, start_time)
    @id = id  
    @start_time = start_time  
  end
end