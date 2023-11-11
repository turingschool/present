class RenameEndToEndTime < ActiveRecord::Migration[7.0]
  def change
    rename_column :student_attendance_hours, :end, :end_time
  end
end
