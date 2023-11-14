desc "Delete duplicate meetings"
task :delete_duplicate_meetings, [:testing_mode_enabled] => :environment do |task, args|
  args.with_defaults(:testing_mode_enabled => true)
  testing = ActiveModel::Type::Boolean.new.cast(args[:testing_mode_enabled])

  duplicate_meeting_ids = ZoomMeeting.group(:meeting_id).count.find_all {|_, count| count > 1}
  duplicate_meeting_ids.each do |meeting_id|
    zooms = ZoomMeeting.where(meeting_id: meeting_id)
    zooms[1..-1].each do |zoom|
      zoom.attendance.destroy
    end
  end

  duplicate_threads = SlackThread.group(:channel_id, :sent_timestamp).count.find_all {|(_, _), count| count > 1}
  # require 'pry';binding.pry
  # duplicate_meeting_ids.each do 
end