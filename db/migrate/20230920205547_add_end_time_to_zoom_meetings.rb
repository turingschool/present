class AddEndTimeToZoomMeetings < ActiveRecord::Migration[7.0]
  def change
    add_column :zoom_meetings, :end_time, :datetime
  end
end
