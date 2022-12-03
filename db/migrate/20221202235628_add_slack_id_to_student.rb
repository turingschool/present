class AddSlackIdToStudent < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :slack_id, :string
  end
end
