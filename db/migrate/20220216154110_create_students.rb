class CreateStudents < ActiveRecord::Migration[5.2]
  def change
    create_table :students do |t|
      t.string :zoom_email
      t.string :zoom_id
      t.string :name

      t.timestamps
    end
  end
end
