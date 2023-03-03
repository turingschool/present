class ZoomMeeting < Meeting
  attr_reader :title

  def initialize(meeting_id, start_time, title, status = :valid)
    super(meeting_id, start_time)
    @title = title
    @status = status
  end

  def self.from_meeting_details(meeting_id)
    meeting_details = ZoomService.meeting_details(meeting_id)    
    if meeting_details[:code] == 3001
      status = :invalid
      start_time = nil
    else
      status = :valid
      start_time = meeting_details[:start_time].to_datetime
    end

  new(meeting_id, start_time, meeting_details[:topic], status)
  end

  def participants
    @participants ||= participant_report.map {|participant| ZoomParticipant.from_meeting(participant)}
  end

  def valid?
    @status == :valid
  end

  def invalid_message
    "It appears you have entered an invalid Zoom Meeting ID. Please double check the Meeting ID and try again."
  end

  def create_child_attendance_record(attendance)
    ZoomAttendance.create!(meeting_time: self.start_time, meeting_title: self.title, zoom_meeting_id: self.id, attendance: attendance)
  end

private
  def participant_report
    @participant_report ||= ZoomService.participant_report(self.id)[:participants]
  end
end
