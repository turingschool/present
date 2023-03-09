class Participant
  attr_reader :id, :join_time, :status

  def initialize(id, join_time)
    # Abstract Class
    raise 'Abstract class Meeting cannot be instantiated' if self.class == Participant
    @id = id
    @join_time = Time.parse(join_time)
  end
end