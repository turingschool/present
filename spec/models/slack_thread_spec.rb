require 'rails_helper'

RSpec.describe SlackThread do
  it {should have_one :attendance}
  it {should have_one(:turing_module).through(:attendance)}
end