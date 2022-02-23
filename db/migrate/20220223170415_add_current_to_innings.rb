class AddCurrentToInnings < ActiveRecord::Migration[5.2]
  def change
    add_column :innings, :current, :boolean, default: false
  end
end
