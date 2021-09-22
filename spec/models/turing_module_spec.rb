require 'rails_helper'

RSpec.describe TuringModule, type: :model do
  it {should validate_presence_of :name}
  it {should validate_presence_of :google_spreadsheet_id}
  it {should validate_presence_of :google_sheet_name}
  it {should belong_to :inning}
  it {should have_many :attendances}
end
