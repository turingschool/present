class RenameZoomAttendanceToMeetingInAliases < ActiveRecord::Migration[5.2]
  def change
    rename_column :zoom_aliases, :zoom_attendance_id, :zoom_meeting_id
  end
end
