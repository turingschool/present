require 'rails_helper'

RSpec.describe GoogleSpreadsheet do
  it {should validate_presence_of :google_id}
  it {should have_many :google_sheets}
end
