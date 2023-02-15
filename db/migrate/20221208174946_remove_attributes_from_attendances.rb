class RemoveAttributesFromAttendances < ActiveRecord::Migration[5.2]
  def change
    remove_column :attendances, :zoom_meeting_id, :string
    remove_column :attendances, :meeting_title, :string
    remove_column :attendances, :meeting_time, :datetime
  end
end
