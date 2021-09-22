class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :google_id
      t.string :email
      t.string :google_oauth_token

      t.timestamps
    end
  end
end
