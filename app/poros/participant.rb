class Participant
  attr_reader :id, :join_time, :status

  def initialize(id, join_time)
    # Abstract Class
    raise 'Abstract class Meeting cannot be instantiated' if self.class == Participant
    @id = id
    @join_time = Time.parse(join_time)
  end

  def find_student
    Student.find_by(id_column_name => id)
  end

# Interfaces
  @@interfaces = [:id_column_name]
  
  @@interfaces.each do |interface|
    define_method(interface) do |*args|
      raise NoMethodError.new("#{self.class} does not implement required method: #{interface}")
    end
  end  
end