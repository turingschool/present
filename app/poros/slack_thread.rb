class SlackThread < Meeting
  attr_reader :message_timestamp, :participants

  def initialize(id, start_time, message_timestamp, participants)
    super(id, start_time)
    @message_timestamp = message_timestamp
    @participants = participants
  end

  def self.from_message_link(message_url)
    channel_id = message_url.split("/")[-2]
    message_timestamp = message_url.split("/").last[1..-1]
    replies_report = SlackService.replies_from_message(channel_id, message_timestamp)
    attendance_start_time = replies_report[:attendance_start_time].to_datetime
    replies = replies_report[:data].map do |reply_info|
      SlackThreadParticipant.new(reply_info[:reply_timestamp], reply_info[:status], reply_info[:slack_id])
    end
    new(message_url, attendance_start_time, message_timestamp, replies)
  end
end