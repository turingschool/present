class CreateInactivePeriods < ActiveRecord::Migration[7.0]
  def change
    create_table :inactive_periods do |t|
      t.references :student, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
