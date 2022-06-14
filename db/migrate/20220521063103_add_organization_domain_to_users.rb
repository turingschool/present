class AddOrganizationDomainToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :organization_domain, :string
  end
end
