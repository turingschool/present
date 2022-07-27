class RemovePairForeignKeyFromStudentPairs < ActiveRecord::Migration[5.2]
  def change
    remove_reference :student_pairs, :pair
    add_reference :student_pairs, :project, foreign_key: true
  end
end
