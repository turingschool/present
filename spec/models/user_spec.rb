require 'rails_helper'

RSpec.describe User, type: :model do
  it {should validate_presence_of :email}
  it {should validate_presence_of :google_oauth_token}
  it {should validate_presence_of :google_id}
end
