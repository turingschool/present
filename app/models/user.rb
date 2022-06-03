class User < ApplicationRecord
  validates_presence_of :google_id, :email, :google_oauth_token

  belongs_to :turing_module, optional: true

  def my_module
    turing_module
  end
end
