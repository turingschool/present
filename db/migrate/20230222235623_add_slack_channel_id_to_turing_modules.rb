class AddSlackChannelIdToTuringModules < ActiveRecord::Migration[5.2]
  def change
    add_column :turing_modules, :slack_channel_id, :string
  end
end
