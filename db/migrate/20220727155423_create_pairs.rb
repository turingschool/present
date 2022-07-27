class CreatePairs < ActiveRecord::Migration[5.2]
  def change
    create_table :pairs do |t|
      t.string :name
      t.integer :size

      t.timestamps
    end
  end
end
