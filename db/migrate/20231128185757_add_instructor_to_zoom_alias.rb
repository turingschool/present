class AddInstructorToZoomAlias < ActiveRecord::Migration[7.0]
  def change
    add_column :zoom_aliases, :instructor, :boolean, default: false
  end
end
