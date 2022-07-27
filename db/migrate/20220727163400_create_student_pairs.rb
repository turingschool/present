class CreateStudentPairs < ActiveRecord::Migration[5.2]
  def change
    create_table :student_pairs do |t|
      t.string :name
      t.references :student, foreign_key: true
      t.references :pair, foreign_key: true

      t.timestamps
    end
  end
end
