class AddMeetingAttributesToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :meeting_title, :string
    add_column :attendances, :meeting_time, :timestamp
  end
end
