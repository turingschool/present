class StudentsAreUniqueByPopuliId < ActiveRecord::Migration[7.0]
  def change
    add_index :students, :populi_id, unique: true
  end
end
