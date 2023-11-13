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
      start_time: start_time,
      presence_check_complete: false
    })
  end

  def message_link
    "https://turingschool.slack.com/archives/#{self.channel_id}/p#{self.sent_timestamp}"
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
    num_hours = ((self.attendance.end_time - self.attendance.attendance_time).to_f / 3600).to_i
    tail_minutes = (((self.attendance.end_time - self.attendance.attendance_time).to_f % 3600) / 60).to_i
    student_attendance_hours = []
    student_attendances = self.attendance.student_attendances
    num_hours.times do |hour|
      start = self.attendance.attendance_time + (hour * 1.hour)
      end_time = start + 1.hour
      student_attendance_hours += student_attendances.map do |student_attendance|
        {student_attendance_id: student_attendance.id, duration: 0, status: :absent, start: start, end_time: end_time}
      end
    end

    if tail_minutes != 0
      start = self.attendance.attendance_time + (num_hours * 1.hour)
      end_time = start + tail_minutes.minutes
      student_attendance_hours += student_attendances.map do |student_attendance|
        {student_attendance_id: student_attendance.id, duration: 0, status: :absent, start: start, end_time: end_time}
      end
    end

    grouped_attendance_hours = student_attendance_hours.group_by do |attendance_hour|
      attendance_hour[:start]
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
          student_attendance_hour = find_attendance_hour(grouped_attendance_hours, student_attendance.id, time_chunk_start)
          student_attendance_hour[:duration] += chunk_length
          present_threshold = ((student_attendance_hour[:end_time] - student_attendance_hour[:start]) / 60 * (5.0 / 6.0)).to_i
          student_attendance_hour[:status] = :present if student_attendance_hour[:duration] >= present_threshold
        end
      end
      time_chunk_start += 15.minutes
    end
    student_attendances.each(&:save)
    StudentAttendanceHour.upsert_all(student_attendance_hours, unique_by: [:student_attendance_id, :start])
    self.update(presence_check_complete: true)
  end

  def find_attendance_hour(grouped_attendance_hours, student_attendance_id, target_time)
    attendance_hours = grouped_attendance_hours.find do |start, attendance_hours|
      target_time - start < 1.hour
    end
    attendance_hours.last.find do |attendance_hour|
      attendance_hour[:student_attendance_id] == student_attendance_id
    end
  end
end