class Participant
  attr_reader :student_id, :join_time, :status

  def initialize(student_id, join_time, status)
    @student_id = message_timestamp
    @join_time = join_time
    @status = status
  end
end