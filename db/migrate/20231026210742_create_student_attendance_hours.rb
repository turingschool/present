class CreateStudentAttendanceHours < ActiveRecord::Migration[7.0]
  def change
    create_table :student_attendance_hours do |t|
      t.datetime :start
      t.datetime :end
      t.integer :duration
      t.integer :status
      t.references :student_attendance, null: false, foreign_key: true

      t.timestamps
    end
  end
end
