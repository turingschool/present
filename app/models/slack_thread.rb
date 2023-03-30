class SlackThread < ApplicationRecord
  has_one :attendance, as: :meeting

  def record
    replies_report = SlackService.replies_from_message(self.channel_id, self.sent_timestamp)
    participants = replies_report[:data].map do |reply_info|
      SlackThreadParticipant.new(reply_info[:slack_id], nil, reply_info[:reply_timestamp], reply_info[:status])
    end
    student_attendances = take_participant_attendance(participants)
    take_absentee_attendance
  end

  def take_participant_attendance(participants)
    participants.each do |participant|
      student = find_student_from_participant(participant)
      next if student.nil?
      create_participant_attendance(student, participant)
    end
  end

  def find_student_from_participant(participant)
    Student.find_by(slack_id: participant.slack_id)
  end

  def create_participant_attendance(student, participant)
    student_attendance = student_attendances.find_or_create_by(student: student)
    if student_attendance.tardy? && participant.status == "present"
      student_attendance.update(status: "present")
    elsif student_attendance.absent? || student_attendance.status.nil?
      student_attendance.update(status: participant.status) 
    end
  end

  def take_absentee_attendance
    student_ids = student_attendances.pluck(:student_id)
    absent_students = turing_module.students.where.not(id: student_ids)
    absent_students.each do |student|
      student_attendances.create(student: student, status: "absent")
    end
  end

  def turing_module
    student_attendances.first.student.turing_module
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
end