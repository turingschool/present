class ZoomMeeting < Meeting
  has_many :zoom_aliases

  def self.from_meeting_details(meeting_url)
    meeting_id = meeting_url.split("/").last
    meeting_details = ZoomService.meeting_details(meeting_id)

    raise invalid_error if meeting_details[:code] == 3001
    raise no_meeting_error if meeting_details[:code] == 2300
    raise personal_meeting_error if meeting_details[:start_time].nil?
    
    start_time = meeting_details[:start_time].to_datetime
    end_time = start_time + meeting_details[:duration].minutes

    create(
      meeting_id: meeting_id, 
      start_time: start_time, 
      end_time: end_time, 
      title: meeting_details[:topic],
      duration: (meeting_details[:duration])
    )
  end

  def take_participant_attendance
    raise ZoomMeeting.participants_not_ready_error if participant_report.nil?
    create_zoom_aliases if zoom_aliases.empty? # If we are retaking attendance no need to recreate zoom aliases
    grouped_participants = participants.group_by(&:name)
    turing_module.students.each do |student|
      # REFACTOR: use upsert_all instead
      # take_attendance_for_student(student)
      matching_participants = student.zoom_aliases.pluck(:name).flat_map do |zoom_name|
        grouped_participants[zoom_name]
      end.compact
      total_duration = calculate_duration(matching_participants)
      record_student_attendance(student, matching_participants, total_duration)
    end
  end

  # def take_attendance_for_student(student)
  #   matching_participants = participants.find_all do |participant|
  #     student.zoom_aliases.pluck(:name).include?(participant.name)
  #   end
  #   total_duration = matching_participants.sum(&:duration)
  #   best_status = best_status(matching_participants)
  #   student_attendance = attendance.student_attendances.find_or_create_by(student: student)
  #   student_attendance.update(duration: total_duration, status: best_status)
  #   # require 'pry';binding.pry if student.name == "Lacey Weaver"
  # end

  def participants
    @participants ||= create_participant_objects
  end

  def uniq_participants_by_name
    participants.uniq(&:name)
  end

  def find_student_from_participant(participant)
    zoom_alias = find_or_create_zoom_alias(participant.name)
    return zoom_alias.student if zoom_alias
  end

  def connect_alias(student_attendance, name)
    zoom_alias = turing_module.zoom_aliases.find_by(name: name)
    student_attendance.update(zoom_alias: zoom_alias)
  end

private
  def self.invalid_error
    InvalidMeetingError.new("It appears you have entered an invalid Zoom Meeting ID. Please double check the Meeting ID and try again.")
  end
  
  def self.no_meeting_error
    InvalidMeetingError.new("Please enter a Zoom or Slack link.")
  end

  def self.personal_meeting_error
    InvalidMeetingError.new("It looks like that Zoom link is for a Personal Meeting Room. You will need to use a unique meeting instead.")
  end

  def self.participants_not_ready_error
    InvalidMeetingError.new("That Zoom Meeting does not have any participants yet. This could be because the meeting is still in progress. Please try again later.")
  end

  def participant_report
    @report ||= ZoomService.participant_report(self.meeting_id)[:participants]
  end

  def create_participant_objects
    participant_report.map do |participant| 
      ZoomParticipant.new(participant, self.start_time, self.end_time)
    end
  end

  def uniq_participants_best_time(participants)
    grouped_by_name = participants.group_by(&:name)
    participants_best_time = grouped_by_name.map do |name, participant_records|
      earliest_join_time = participant_records.min_by(&:join_time)
      earliest_join_time.duration = calculate_duration(participant_records)
      earliest_join_time
    end
  end

  def calculate_duration(participant_records) 
    ((participant_records.sum(&:duration).to_f) / 60 ).round
  end

  def create_zoom_aliases
    aliases = participant_report.map do |participant|
      {
        name: participant[:name], 
        zoom_meeting_id: self.id, 
        turing_module_id: self.turing_module.id
      }
    end
    ZoomAlias.insert_all(aliases, unique_by: [:name, :turing_module_id])
  end

  def find_or_create_zoom_alias(name)
    zoom_alias = turing_module.zoom_aliases.find_by(name: name)
    return zoom_alias if zoom_alias
    self.zoom_aliases.create!(name: name)
    return nil
  end  
end