class ZoomMeeting < Meeting
  include StringMatcher

  attr_reader :title

  attr_accessor :attendance_time

  def initialize(meeting_id, start_time, title)
    super(meeting_id, start_time)
    @title = title
    @attendance_time = nil
  end

  def self.from_meeting_details(meeting_url)
    meeting_id = meeting_url.split("/").last
    meeting_details = ZoomService.meeting_details(meeting_id)    
    raise invalid_error if meeting_details[:code] == 3001
    new(meeting_id, meeting_details[:start_time].to_datetime, meeting_details[:topic])
  end

  def self.invalid_error
    InvalidMeetingError.new("It appears you have entered an invalid Zoom Meeting ID. Please double check the Meeting ID and try again.")
  end

  def create_child_attendance_record(attendance)
    ZoomAttendance.create!(meeting_time: self.start_time, meeting_title: self.title, zoom_meeting_id: self.id, attendance: attendance)
  end

  def participants
    @participants ||= synthesize_participant_report
  end

  def participants_by_match(student)
    participants.sort_by do |participant|
      string_distance(student.name, participant.name)
    end.reverse
  end

  def assign_participant_statuses(attendance_time)
    participants.each do |participant|
      participant.assign_status(attendance_time)
    end
  end

private
  def participant_report
    @report ||= ZoomService.participant_report(self.id)[:participants]
  end

  def synthesize_participant_report
    participants = create_participant_objects
    uniq_participants_best_time(participants)
  end

  def create_participant_objects
    participant_report.map do |participant| 
      ZoomParticipant.from_meeting(participant)
    end
  end

  def uniq_participants_best_time(participants)
    grouped_by_name = participants.group_by(&:name)
    participants_best_time = grouped_by_name.map do |name, participant_records|
      participant_records.min_by(&:join_time)
    end
  end
end
