class PopuliMeeting
  attr_reader :id, :start_at, :end_at

  def initialize(data)
    @id = data[:id]
    @start_at = Time.parse(data[:start_at])
    @end_at = Time.parse(data[:end_at])
  end
end