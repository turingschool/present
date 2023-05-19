class User < ApplicationRecord
  validates_presence_of :google_id, :email, :google_oauth_token

  belongs_to :turing_module, optional: true

  enum :user_type, [:default, :admin]

  def my_module
    turing_module
  end

  def valid_google_user?
    organization_domain == 'turing.edu'
  end

  def is_this_my_mod?(turing_module)
    return false if my_module.nil?
    my_module.id == turing_module.id
  end
end
