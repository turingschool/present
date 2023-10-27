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

  def record_duration_from_presence_checks!
    # First create the student attendance hours,
    # Then as we're checking duration, also update the attendance hours
    num_hours = ((self.attendance.end_time - self.attendance.attendance_time).to_f / 3600).to_i
    student_attendance_hours = [{start: , end: , duration: , status: , student_attendance_id: }]
    student_attendances = self.attendance.student_attendances
    num_hours.times do |hour|
      start = self.attendance.attendance_time + (hour * 1.hour)
      end_time = start + 1.hour
      student_attendance_hours += student_attendances.map do |student_attendance|
        {student_attendance_id: student_attendance.id, duration: 0, status: :absent, start: start, end: end_time}
      end
    end
    time_chunk_start = self.attendance.attendance_time
    student_attendances = self.attendance.student_attendances.includes(:student)
    student_attendances.update_all(duration: 0)
    until time_chunk_start >= self.attendance.end_time
      time_chunk_end = time_chunk_start + 15.minutes
      time_chunk_end = self.attendance.end_time if time_chunk_end > self.attendance.end_time
      student_attendances.each do |student_attendance|
        successful_checks = SlackPresenceCheck.where(student: student_attendance.student, presence: :active, check_time: time_chunk_start...time_chunk_end)
        if successful_checks.any?
          chunk_length = ((time_chunk_end - time_chunk_start).to_f / 60).to_i
          student_attendance.duration += chunk_length
        end
      end
      time_chunk_start += 15.minutes
    end
    student_attendances.each(&:save)


  end
end