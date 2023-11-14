require 'rails_helper'

RSpec.describe StudentAttendanceHour do
  describe 'relationships' do
    it {should belong_to :student_attendance}
    it {should have_one(:attendance).through(:student_attendance)}
  end

  it {should define_enum_for(:status).with_values([:present, :absent])}

  describe 'class methods' do
    describe ".total" do
      before :each do
        @student = create(:setup_student, :with_attendances)
        @student_attendance_hours = @student.report("2023-11-06", "2023-11-07")
      end

      it "can total all eligible hours" do
        expect(@student_attendance_hours.total).to eq(12.hours + 30.minutes)
      end

      it 'can total all earned hours' do
        expect(@student_attendance_hours.total(status: :present)).to eq(7.hours + 30.minutes)
      end
      
      it "can total all eligible Lesson hours" do
        expect(@student_attendance_hours.total(meeting_type: "ZoomMeeting")).to eq(6.hours + 30.minutes)
      end

      it 'can total all earned Lesson hours' do
        expect(@student_attendance_hours.total(status: :present, meeting_type: "ZoomMeeting")).to eq(3.hours + 30.minutes)
      end

      it "can total all eligible Lab hours" do
        expect(@student_attendance_hours.total(meeting_type: "SlackThread")).to eq(6.hours)
      end

      it 'can total all earned Lab hours' do
        expect(@student_attendance_hours.total(status: :present, meeting_type: "SlackThread")).to eq(4.hours)
      end

      it 'is not affected by other attendance hours' do
        create(:setup_student, :with_attendances)
        expect(@student_attendance_hours.total).to eq(12.hours + 30.minutes)
      end

      it 'will still return a duration if there are no matching attendance hours' do
        expect(@student_attendance_hours.total(meeting_type: "THIS IS NOT A MEETING TYPE")).to be_a(ActiveSupport::Duration)
      end
    end
  end
end