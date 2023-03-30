require 'rails_helper'

RSpec.describe SlackThread do
  it {should have_one :attendance}
end