class PopuliMeeting
  attr_reader :id, :start

  def initialize(data)
    @id = data[:meetingid]
    @start = Time.parse(data[:start])
  end
end