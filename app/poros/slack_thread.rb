class SlackThread < Meeting
  attr_reader :channel_id, :message_timestamp, :participants

  def initialize(id, start_time, channel_id, message_timestamp, participants)
    super(id, start_time)
    @message_timestamp = message_timestamp
    @participants = participants
    @channel_id = channel_id
  end

  def self.from_message_link(message_url)
    channel_id = message_url.split("/")[-2]
    message_timestamp = message_url.split("/").last[1..-1]
    replies_report = SlackService.replies_from_message(channel_id, message_timestamp)
    attendance_start_time = replies_report[:attendance_start_time].to_datetime
    replies = replies_report[:data].map do |reply_info|
      SlackThreadParticipant.new(reply_info[:slack_id], reply_info[:reply_timestamp])
    end
    new(message_url, attendance_start_time, channel_id, message_timestamp, replies)
  end

  def valid?
    start_time.present?
  end

  def invalid_message
    "Slack Message Link not valid"
  end

  def create_child_attendance_record(attendance)
    SlackAttendance.create(channel_id: channel_id, sent_timestamp: message_timestamp, attendance_start_time: start_time , attendance: attendance)
  end
end