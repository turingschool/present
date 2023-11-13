desc "Find all attendances with no end times and recreate"
task :backfill_endtimes => :environment do |task|
  
  ZoomMeeting.joins(:inning).where(inning: {current: true}, attendance: {end_time: nil}).each do |zoom|
    begin
      CreateAttendanceFacade.take_attendance(zoom.meeting_id, zoom.turing_module, zoom.attendance.user)
    rescue InvalidMeetingError => e
      puts "Unable to take attendance for Zoom Meeting #{zoom.meeting_id}. Message: #{e.message}" 
    end
  end

  SlackThread.joins(:inning).where(inning: {current: true}, attendance: {end_time: nil}).each do |slack|
    CreateAttendanceFacade.take_attendance(slack.message_link, slack.turing_module, slack.attendance.user)
  end
end