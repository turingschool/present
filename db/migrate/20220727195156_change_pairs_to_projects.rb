class ChangePairsToProjects < ActiveRecord::Migration[5.2]
  def change
    rename_table :pairs, :projects
  end
end
