class AddDurationToZoomMeetings < ActiveRecord::Migration[7.0]
  def change
    add_column :zoom_meetings, :duration, :integer
  end
end
