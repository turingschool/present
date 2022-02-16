class AddStudentsToModules < ActiveRecord::Migration[5.2]
  def change
    add_reference :students, :turing_module, foreign_key: true
  end
end
