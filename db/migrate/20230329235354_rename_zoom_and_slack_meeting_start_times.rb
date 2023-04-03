class RenameZoomAndSlackMeetingStartTimes < ActiveRecord::Migration[5.2]
  def change
    rename_column :zoom_meetings, :meeting_time, :start_time
    rename_column :slack_threads, :attendance_start_time, :start_time
  end
end
