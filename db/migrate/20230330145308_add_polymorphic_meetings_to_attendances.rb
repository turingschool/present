class AddPolymorphicMeetingsToAttendances < ActiveRecord::Migration[5.2]
  def change
    remove_column :zoom_meetings, :attendance_id
    remove_column :slack_threads, :attendance_id
    add_reference :attendances, :meeting, polymorphic: true
  end
end
