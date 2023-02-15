class CreateSlackMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :slack_members do |t|
      t.string :slack_user_id
      t.string :name
    end
  end
end
