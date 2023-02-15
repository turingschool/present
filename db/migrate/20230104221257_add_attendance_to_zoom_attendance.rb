class AddAttendanceToZoomAttendance < ActiveRecord::Migration[5.2]
  def change
    add_reference :zoom_attendances, :attendance, foreign_key: true
  end
end
