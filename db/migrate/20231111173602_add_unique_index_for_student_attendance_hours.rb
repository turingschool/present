class AddUniqueIndexForStudentAttendanceHours < ActiveRecord::Migration[7.0]
  def change
    add_index :student_attendance_hours, [:student_attendance_id, :start], unique: true, name: "student_attendance_hours_unique_by_student_attendance_and_start"
  end
end
