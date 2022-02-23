class CreateStudentAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :student_attendances do |t|
      t.integer :status
      t.references :student, foreign_key: true
      t.references :attendance, foreign_key: true
      t.datetime :join_time

      t.timestamps
    end
  end
end
