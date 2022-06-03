class AddCurrentModuleToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :turing_module
  end
end
