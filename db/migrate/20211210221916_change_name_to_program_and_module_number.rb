class ChangeNameToProgramAndModuleNumber < ActiveRecord::Migration[5.2]
  def change
    remove_column :turing_modules, :name
    add_column :turing_modules, :program, :integer
    add_column :turing_modules, :module_number, :integer
  end
end
