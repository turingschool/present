class AddAttendanceToSlackAttendance < ActiveRecord::Migration[5.2]
  def change
    add_reference :slack_attendances, :attendance, foreign_key: true
  end
end
