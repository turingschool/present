class ZoomMeeting
  attr_reader :id, :title, :start_time, :participants

  def initialize(meeting_id)
    @id = meeting_id
    @title = meeting_details[:topic]
    @start_time = meeting_details[:start_time]
  end

  def participants
    @participants ||= participant_report.map {|participant| ZoomParticipant.from_meeting(participant)}
  end

  def meeting_details
    @meeting_details ||= ZoomService.meeting_details(@id)
  end

  def valid_id?
    return false if meeting_details[:code] == 3001
    return true
  end

private
  def participant_report
    @participant_report ||= ZoomService.participant_report(@id)[:participants]
  end
end
