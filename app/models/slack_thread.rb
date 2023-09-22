class SlackThread < Meeting
  def find_student_from_participant(participant)
    turing_module.students.find_by(slack_id: participant.slack_id)
  end

  def self.from_message_link(message_url)
    channel_id = message_url.split("/")[-2]
    sent_timestamp = message_url.split("/").last[1..-1]
    replies_report = SlackService.replies_from_message(channel_id, sent_timestamp)
    start_time = replies_report[:attendance_start_time].to_datetime
    create({
      channel_id: channel_id,
      sent_timestamp: sent_timestamp,
      start_time: start_time  
    })
  end

  def participants
    replies_report = SlackService.replies_from_message(channel_id, sent_timestamp)
    replies = replies_report[:data].map do |reply_info|
      SlackThreadParticipant.new(reply_info)
    end
  end

  def title
    "Slack Thread"
  end

  def take_participant_attendance
    grouped_participants = participants.group_by(&:slack_id)
    turing_module.students.each do |student|
      matching_participants = grouped_participants[student.slack_id] || []
      record_student_attendance(student, matching_participants, 0)
    end
  end
end