class AddUsersToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_reference :attendances, :user, foreign_key: true
  end
end
