class User < ApplicationRecord
  validates_presence_of :google_id, :email, :google_oauth_token
end
