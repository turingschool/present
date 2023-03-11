class ZoomMeeting < Meeting
  include StringMatcher

  attr_reader :title

  attr_accessor :attendance_time

  def initialize(meeting_id, start_time, title)
    super(meeting_id, start_time)
    @title = title
    @attendance_time = nil
  end

  def participants
    @participants ||= synthesize_participant_report
  end

  def self.from_meeting_details(meeting_id)
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

  def participants_by_match(student)
    participants.sort_by do |participant|
      string_distance(student.name, participant.name)
    end.reverse
  end

private
  def synthesize_participant_report
    participants = create_participant_objects
    uniq_participants_best_time(participants)
  end

  def create_participant_objects
    participant_report.map do |participant| 
      ZoomParticipant.from_meeting(participant, self.attendance_time)
    end
  end

  def uniq_participants_best_time(participants)
    grouped_by_name = participants.group_by(&:name)
    participants_best_time = grouped_by_name.map do |name, participant_records|
      participant_records.min_by(&:join_time)
    end
  end

  def participant_report
    @report ||= ZoomService.participant_report(self.id)[:participants]
  end

  # def attendance_time
  #   distance_to_top = start_time - start_time.end_of_hour
  #   distance_to_bottom = start_time - start_time.beginning_of_hour
  #   if distance_to_top < distance_to_bottom
  #     return start_time.end_of_hour
  #   else
  #     return start_time.beginning_of_hour
  #   end
  # end
end
