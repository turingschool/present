class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances do |t|
      t.references :turing_module, foreign_key: true
      t.string :zoom_meeting_id

      t.timestamps
    end
  end
end
