class PopuliMeeting
  attr_reader :id, :start, :end

  def initialize(data)
    @id = data[:meetingid]
    @start = Time.parse(data[:start])
    @end = Time.parse(data[:end])
  end
end