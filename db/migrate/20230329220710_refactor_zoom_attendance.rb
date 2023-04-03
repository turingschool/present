class RefactorZoomAttendance < ActiveRecord::Migration[5.2]
  def change
    rename_table :zoom_attendances, :zoom_meetings
    rename_column :zoom_meetings, :zoom_meeting_id, :meeting_id
    rename_column :zoom_meetings, :meeting_title, :title
  end
end
