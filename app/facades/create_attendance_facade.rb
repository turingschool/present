class CreateAttendanceFacade
  def self.run(attendance, user, populate_students)
    # Get meeting details (startime, duration)
    # Get Participant report
    # If we're populating attendance
      # Use participant report to create students
    # meeting_details = ZoomService.meeting_details(attendance.zoom_meeting_id)
    participants = ZoomService.past_participants_meeting_report(attendance.zoom_meeting_id)[:participants]
    attendance.turing_module.create_students_from_participants(participants) if populate_students
    # Use meeting details, participant report,
    # and module's students to create attendance values
    # Update the Google Sheet
    # ZoomFacade.past_participants_in_meeting
    AttendanceTaker.take_attendance(attendance, user)
  end
end
