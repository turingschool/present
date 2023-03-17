class AddAttendancesToZoomAliass < ActiveRecord::Migration[5.2]
  def change
    add_reference :zoom_aliases, :zoom_attendance, foreign_key: true
  end
end
