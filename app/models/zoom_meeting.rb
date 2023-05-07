class ZoomMeeting < Meeting
  has_many :zoom_aliases
  has_one :attendance, as: :meeting
  has_one :turing_module, through: :attendance

  def self.from_meeting_details(meeting_url)
    meeting_id = meeting_url.split("/").last
    meeting_details = ZoomService.meeting_details(meeting_id)    
    raise invalid_error if meeting_details[:code] == 3001
    raise no_meeting_error if meeting_details[:code] == 2300
    create(
      meeting_id: meeting_id, 
      start_time: meeting_details[:start_time].to_datetime, 
      title: meeting_details[:topic]
    )
  end

  def participants
    @participants ||= synthesize_participant_report
  end

  def unclaimed_aliases
    # We don't necessarily care which zoom alias is picked for each name, 
    # so just get the one with the minimum id
    self.zoom_aliases.where(student: nil).group(:name).minimum(:id)
  end

  def find_student_from_participant(participant)
    zoom_alias = find_or_create_zoom_alias(participant.name)
    return zoom_alias.student if zoom_alias
  end

  def find_or_create_zoom_alias(name)
    zoom_alias = turing_module.zoom_aliases.find_by(name: name)
    return zoom_alias if zoom_alias
    self.zoom_aliases.create!(name: name)
    return nil
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

  def participant_report
    @report ||= ZoomService.participant_report(self.meeting_id)[:participants]
  end

  def synthesize_participant_report
    participants = create_participant_objects
    uniq_participants_best_time(participants)
  end

  def create_participant_objects
    participant_report.map do |participant| 
      ZoomParticipant.new(participant)
    end
  end

  def uniq_participants_best_time(participants)
    grouped_by_name = participants.group_by(&:name)
    participants_best_time = grouped_by_name.map do |name, participant_records|
      participant_records.min_by(&:join_time)
    end
  end
end