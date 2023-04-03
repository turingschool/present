class ChangeSentTimestampToString < ActiveRecord::Migration[5.2]
  def change
    change_column :slack_threads, :sent_timestamp, :string
  end
end
