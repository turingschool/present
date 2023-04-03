class RefactorSlackAttendance < ActiveRecord::Migration[5.2]
  def change
    rename_table :slack_attendances, :slack_threads
  end
end
