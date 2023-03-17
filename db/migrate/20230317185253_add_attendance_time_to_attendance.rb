class AddAttendanceTimeToAttendance < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :attendance_time, :datetime
  end
end
