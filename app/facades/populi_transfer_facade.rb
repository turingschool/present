class PopuliTransferFacade
  include ApplicationHelper

  attr_reader :attendance

  def initialize(attendance)
    @attendance = attendance
  end

  def turing_module
    attendance.turing_module
  end

  def populi_meeting_options
    meetings = attendance.meeting.populi_meetings_on_same_day(turing_module.populi_course_id)
    meetings.map do |populi_meeting|
      ["#{pretty_time(populi_meeting.start)}", populi_meeting.id]
    end
  end

  def populi_meeting_selection
    attendance.meeting.closest_populi_meeting_to_start_time(turing_module.populi_course_id).id
  end
end