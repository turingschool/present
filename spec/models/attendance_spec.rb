require 'rails_helper'

RSpec.describe Attendance, type: :model do
  describe 'validations' do
    it {should validate_presence_of :attendance_time}
  end

  describe 'relationships' do
    it {should belong_to :turing_module}
    it {should belong_to :user}
    it {should belong_to(:meeting)} 
    it {should have_many :student_attendances}
    it {should have_many(:students).through(:student_attendances)}
  end
end
