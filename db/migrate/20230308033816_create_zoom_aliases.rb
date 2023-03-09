class CreateZoomAliases < ActiveRecord::Migration[5.2]
  def change
    create_table :zoom_aliases do |t|
      t.string :name
      t.references :student

      t.timestamps
    end
  end
end
