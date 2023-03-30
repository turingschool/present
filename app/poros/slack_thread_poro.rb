class SlackThreadPoro < Meeting
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
    # TODO Any errors we can raise here based on the replies report?
    replies_report = SlackService.replies_from_message(channel_id, message_timestamp)
    attendance_start_time = replies_report[:attendance_start_time].to_datetime
    replies = replies_report[:data].map do |reply_info|
      SlackThreadParticipant.new(reply_info[:slack_id], nil, reply_info[:reply_timestamp], reply_info[:status])
    end
    new(message_url, attendance_start_time, channel_id, message_timestamp, replies)
  end

  def assign_participant_statuses(attendance_time)
    # TODO we probably need the slack thread to assign statuses using the populi attendance time
    return
  end

  def invalid_message
    "Slack Message Link not valid"
  end
end