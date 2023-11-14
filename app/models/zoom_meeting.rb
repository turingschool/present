class ZoomMeeting < Meeting
  has_many :zoom_aliases, dependent: :destroy

  validates_uniqueness_of :meeting_id

  def self.from_meeting_details(meeting_url)
    meeting_id = meeting_url.split("/").last
    meeting_details = ZoomService.meeting_details(meeting_id)

    raise invalid_error if meeting_details[:code] == 3001
    raise no_meeting_error if meeting_details[:code] == 2300
    raise personal_meeting_error if meeting_details[:start_time].nil?
    
    start_time = meeting_details[:start_time].to_datetime
    end_time = start_time + meeting_details[:duration].minutes
    
    attributes = {
      start_time: start_time, 
      end_time: end_time, 
      title: meeting_details[:topic],
      duration: (meeting_details[:duration])
    }
    zoom = ZoomMeeting.find_or_create_by(meeting_id: meeting_id)
    zoom.update(attributes)
    return zoom
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
      student_attendance = record_student_attendance(student, matching_participants, total_duration)
      record_student_attendance_hours(matching_participants, student_attendance)
    end
  end

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
      ZoomParticipant.new(participant, attendance.attendance_time, attendance.end_time)
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

  def record_student_attendance_hours(matching_participants, student_attendance)
    num_hours = ((self.attendance.end_time - self.attendance.attendance_time).to_f / 3600).to_i
    num_hours.times do |hour|
      start = self.attendance.attendance_time + (hour * 1.hour)
      end_time = start + 1.hour
      time_in_hour = calculate_time_in_hour(start, end_time, matching_participants)
      status = time_in_hour >= 50 ? :present : :absent
      attributes = {start: start, end_time: end_time, duration: time_in_hour, status: status}
      attendance_hour = student_attendance.student_attendance_hours.upsert(attributes, unique_by: [:student_attendance_id, :start])
    end
  end

  def calculate_time_in_hour(start_time, end_time, participants)
    seconds = participants.sum do |participant|
      if participant.join_time >= start_time && participant.leave_time < end_time # this participation falls within the hour
        participant.duration
      elsif participant.join_time < start_time && participant.leave_time > end_time # this participation starts before the hour and ends after the hour
        3600
      elsif participant.join_time < end_time && participant.leave_time > end_time # this participation starts within the hour and extends beyond the hour
        end_time - participant.join_time
      elsif participant.join_time < start_time && participant.leave_time > start_time # this participation starts before the hour and ends within the hour
        participant.leave_time - start_time
      else # this participation does not overlap with the hour at all
        0
      end
    end
    (seconds.to_f / 60).round
  end
end