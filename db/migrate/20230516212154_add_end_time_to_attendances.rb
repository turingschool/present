class AddEndTimeToAttendances < ActiveRecord::Migration[7.0]
  def change
    add_column :attendances, :end_time, :datetime
  end
end
