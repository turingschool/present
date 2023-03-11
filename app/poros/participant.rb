class Participant
  attr_reader :id, :name, :join_time, :status

  def initialize(id, name, join_time, status)
    @id = id
    @name = name
    @join_time = join_time
    @status = status
  end
end