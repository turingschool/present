class RemoveZoomAliasesFromStudentAttendance < ActiveRecord::Migration[7.0]
  def change
    remove_column :student_attendances, :zoom_alias_id
  end
end
