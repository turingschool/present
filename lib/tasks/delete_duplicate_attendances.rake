desc "Delete duplicate meetings"
task :delete_duplicate_attendances, [:testing_mode_enabled] => :environment do |task, args|
  args.with_defaults(:testing_mode_enabled => true)
  testing = ActiveModel::Type::Boolean.new.cast(args[:testing_mode_enabled])

  duplicate_meeting_ids = ZoomMeeting.group(:meeting_id).count.find_all {|_, count| count > 1}
  duplicate_meeting_ids.each do |meeting_id, _|
    zooms = ZoomMeeting.where(meeting_id: meeting_id)
    zooms[1..-1].each do |zoom| # Destroy all except the first
      zoom.attendance.destroy
      zoom.destroy
    end
  end

  duplicate_threads = SlackThread.group(:channel_id, :sent_timestamp).count.find_all {|(_, _), count| count > 1}
  duplicate_threads.each do |(channel_id, sent_timestamp), _|
    slacks = SlackThread.where(channel_id: channel_id, sent_timestamp: sent_timestamp)
    slacks[1..-1].each do |slack| # Destroy all except the first
      slack.attendance.destroy
      slack.destroy
    end
  end
end