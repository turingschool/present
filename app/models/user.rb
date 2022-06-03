class User < ApplicationRecord
  validates_presence_of :google_id, :email, :google_oauth_token

  belongs_to :turing_module, optional: true

  def my_module
    turing_module
  end

  def valid_google_user?
    organization_domain == 'turing.edu'
  end
end
