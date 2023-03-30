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

  describe 'instance methods' do
    describe 'pretty_time' do
      it 'returns hours and minutes in mountain time' do
        attendance_1 = create(:attendance, attendance_time: DateTime.parse('2021-12-17T16:00:00Z')) # 9am mountain
        attendance_2 = create(:attendance, attendance_time: DateTime.parse('2021-12-17T20:00:00Z')) # 1pm mountain
        attendance_3 = create(:attendance, attendance_time: DateTime.parse('2021-12-17T18:59:59Z')) # 11:59:59am mountain
        expect(attendance_1.pretty_time).to eq('9:00 AM')
        expect(attendance_2.pretty_time).to eq('1:00 PM')
        expect(attendance_3.pretty_time).to eq('11:59 AM')
      end
    end
  end
end
