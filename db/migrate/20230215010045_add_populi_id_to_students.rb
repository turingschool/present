class AddPopuliIdToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :populi_id, :string
  end
end
