class DropSlackMembers < ActiveRecord::Migration[5.2]
  def change
    drop_table :slack_members
  end
end
