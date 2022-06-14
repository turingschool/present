class AddCalendarIntegrationToModules < ActiveRecord::Migration[5.2]
  def change
    add_column :turing_modules, :calendar_integration, :boolean, default: false
  end
end
