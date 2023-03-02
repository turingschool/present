class SlackThread < Meeting
  attr_reader :message_timestamp, :replies

  def initialize(id, start_time, message_timestamp, replies)
    super(id, start_time)
    @message_timestamp = message_timestamp
    @replies = replies
  end

  def self.from_message_link(message_url)
    channel_id = message_url.split("/")[-2]
    message_timestamp = message_url.split("/").last[1..-1]
    replies_report = SlackService.replies_from_message(channel_id, message_timestamp)
    attendance_start_time = replies_report[:attendance_start_time].to_datetime
    new(message_url, attendance_start_time, message_timestamp, replies_report[:data])
  end
end