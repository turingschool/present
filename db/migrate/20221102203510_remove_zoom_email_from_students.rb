class RemoveZoomEmailFromStudents < ActiveRecord::Migration[5.2]
  def change
    remove_column :students, :zoom_email, :string
  end
end
