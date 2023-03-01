class CreateSlackAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :slack_attendances do |t|
      t.string :channel_id
      t.timestamp :sent_timestamp
      t.timestamp :attendance_start_time
    end
  end
end
