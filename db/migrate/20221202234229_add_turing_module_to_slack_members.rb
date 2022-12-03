class AddTuringModuleToSlackMembers < ActiveRecord::Migration[5.2]
  def change
    add_reference :slack_members, :turing_module, foreign_key: true
  end
end
