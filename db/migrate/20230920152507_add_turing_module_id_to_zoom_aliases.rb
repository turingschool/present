class AddTuringModuleIdToZoomAliases < ActiveRecord::Migration[7.0]
  def change
    add_reference :zoom_aliases, :turing_module, foreign_key: true
    add_index :zoom_aliases, [:name, :turing_module_id], unique: true
  end
end
