class AddStartDateToInnings < ActiveRecord::Migration[7.0]
  def change
    add_column :innings, :start_date, :date
  end
end
