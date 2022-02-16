require 'rails_helper'

RSpec.describe Attendance, type: :model do
  describe 'validations' do
    it {should validate_presence_of :zoom_meeting_id}
    it {should validate_uniqueness_of :zoom_meeting_id}
  end

  describe 'relationships' do
    it {should belong_to :turing_module}
    it {should belong_to :user}
    it {should have_many :student_attendances}
    it {should have_many(:students).through(:student_attendances)}
  end
end
