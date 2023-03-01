class CreateZoomAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :zoom_attendances do |t|
      t.string :zoom_meeting_id
      t.string :meeting_title
      t.timestamp :meeting_time
    end
  end
end
