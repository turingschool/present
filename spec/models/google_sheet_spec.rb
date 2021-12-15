require 'rails_helper'

RSpec.describe GoogleSheet do
  it {should validate_presence_of :name}
  it {should validate_presence_of :google_id}
  it {should belong_to :google_spreadsheet}
  it {should belong_to :turing_module}
end
