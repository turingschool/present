class AddPopuliCourseIdToModules < ActiveRecord::Migration[5.2]
  def change
    add_column :turing_modules, :populi_course_id, :string
  end
end
