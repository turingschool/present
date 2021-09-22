require 'rails_helper'

RSpec.describe Attendance, type: :model do
  it {should validate_presence_of :zoom_meeting_id}
  it {should belong_to :turing_module}
  it {should belong_to :user}
  it {should validate_uniqueness_of :zoom_meeting_id}
end
