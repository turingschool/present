class RemoveZoomIdFromStudents < ActiveRecord::Migration[5.2]
  def change
    remove_column :students, :zoom_id
  end
end
1