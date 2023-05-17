class CreateSlackPresenceChecks < ActiveRecord::Migration[7.0]
  def change
    create_table :slack_presence_checks do |t|
      t.datetime :check_time
      t.references :student, null: false, foreign_key: true
      t.integer :presence

      t.timestamps
    end
  end
end
