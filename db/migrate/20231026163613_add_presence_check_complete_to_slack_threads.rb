class AddPresenceCheckCompleteToSlackThreads < ActiveRecord::Migration[7.0]
  def change
    add_column :slack_threads, :presence_check_complete, :boolean
  end
end
