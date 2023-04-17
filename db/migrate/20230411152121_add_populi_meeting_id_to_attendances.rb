class AddPopuliMeetingIdToAttendances < ActiveRecord::Migration[7.0]
  def change
    add_column :attendances, :populi_meeting_id, :string
  end
end
