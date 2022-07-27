class DropStudentPairsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :student_pairs
  end
end
