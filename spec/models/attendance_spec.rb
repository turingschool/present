require 'rails_helper'

RSpec.describe Attendance, type: :model do
  describe 'validations' do
    it {should validate_presence_of :attendance_time}
  end

  describe 'relationships' do
    it {should belong_to :turing_module}
    it {should belong_to :user}
    it {should have_one(:slack_attendance).optional} 
    it {should have_one(:zoom_attendance).optional}
    it {should have_many :student_attendances}
    it {should have_many(:students).through(:student_attendances)}
  end

  describe 'instance methods' do
    describe '#am_or_pm' do
      it 'should return am if time is before noon mountain' do
        attendance_1 = create(:zoom_attendance, meeting_time: DateTime.parse('2021-12-17T16:00:00Z')) # 9am mountain
        attendance_2 = create(:zoom_attendance, meeting_time: DateTime.parse('2021-12-17T17:00:00Z')) # 10am mountain
        attendance_3 = create(:zoom_attendance, meeting_time: DateTime.parse('2021-12-17T18:59:59Z')) # 11:59:59am mountain
        expect(attendance_1.am_or_pm).to eq("AM")
        expect(attendance_2.am_or_pm).to eq("AM")
        expect(attendance_3.am_or_pm).to eq("AM")
      end

      it 'should return pm if the time is noon mountain or later' do
        attendance_1 = create(:zoom_attendance, meeting_time: DateTime.parse('2021-12-17T20:00:00Z')) # 1pm mountain
        attendance_2 = create(:zoom_attendance, meeting_time: DateTime.parse('2021-12-17T19:00:00Z')) # 12:00pm mountain
        expect(attendance_1.am_or_pm).to eq("PM")
        expect(attendance_2.am_or_pm).to eq("PM")
      end
    end

    describe 'pretty_time' do
      it 'returns hours and minutes in mountain time' do
        attendance_1 = create(:zoom_attendance, meeting_time: DateTime.parse('2021-12-17T16:00:00Z')) # 9am mountain
        attendance_2 = create(:zoom_attendance, meeting_time: DateTime.parse('2021-12-17T20:00:00Z')) # 1pm mountain
        attendance_3 = create(:zoom_attendance, meeting_time: DateTime.parse('2021-12-17T18:59:59Z')) # 11:59:59am mountain
        expect(attendance_1.pretty_time).to eq('9:00 AM')
        expect(attendance_2.pretty_time).to eq('1:00 PM')
        expect(attendance_3.pretty_time).to eq('11:59 AM')
      end
    end
  end
end
