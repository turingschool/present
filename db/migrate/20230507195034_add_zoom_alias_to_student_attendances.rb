class AddZoomAliasToStudentAttendances < ActiveRecord::Migration[7.0]
  def change
    add_reference :student_attendances, :zoom_alias
  end
end
