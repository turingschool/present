class AddDurationToStudentAttendances < ActiveRecord::Migration[7.0]
  def change
    add_column :student_attendances, :duration, :integer
  end
end
