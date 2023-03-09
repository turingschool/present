class Participant
  attr_reader :id, :join_time, :status

  def initialize(id, join_time)
    @id = id
    @join_time = Time.parse(join_time)
  end
end