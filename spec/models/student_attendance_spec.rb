require 'rails_helper'

RSpec.describe StudentAttendance, type: :model do
  describe 'relationships' do
    it {should belong_to :student}
    it {should belong_to :attendance}
  end

  it {should define_enum_for(:status).with_values(present: 0, tardy: 1, absent: 2)}

  describe 'class methods' do
    describe ".by_attendance_status" do
      it 'orders by attendance status, then by last name' do
        ryan = create(:student, name: 'Ryan T')
        jamie = create(:student, name: 'Jamie P')
        dane = create(:student, name: 'Dane B')
        kevin = create(:student, name: 'Kevin X')

        create(:student_attendance, student: kevin, status: :present )
        create(:student_attendance, student: ryan, status: :absent )
        create(:student_attendance, student: dane, status: :tardy )
        create(:student_attendance, student: jamie, status: :absent )
        
        ordered_list = StudentAttendance.by_attendance_status
        expect(ordered_list.first.student).to eq(jamie)
        expect(ordered_list.second.student).to eq(ryan)
        expect(ordered_list.third.student).to eq(dane)
        expect(ordered_list.fourth.student).to eq(kevin)
      end
    end
  end

  describe 'instance methods' do
    describe '#assign_status' do
      it 'assigns the join time' do
        student_attendance = create(:student_attendance)
        join_time = Time.parse("2021-12-17T15:48:18Z")
        student_attendance.assign_status("present", join_time)
        expect(student_attendance.join_time).to eq(join_time)
      end

      it 'assigns a present status' do
        student_attendance = create(:student_attendance)
        join_time = Time.parse("2021-12-17T15:48:18Z")
        student_attendance.assign_status("present", join_time)
        expect(student_attendance.status).to eq("present")
      end

      it 'overwrites an absent status with a tardy' do
        student_attendance = create(:student_attendance, status: :absent)
        join_time = Time.parse("2021-12-17T16:15:00Z")
        expect(student_attendance.status).to eq('absent')
        expect(student_attendance.join_time).to_not eq(join_time)
        student_attendance.assign_status("tardy", join_time)
        expect(student_attendance.status).to eq('tardy')
        expect(student_attendance.join_time).to eq(join_time)
      end

      it 'overwrites an absent status with a present' do
        student_attendance = create(:student_attendance, status: :absent)
        join_time = Time.parse("2021-12-17T16:00:00Z")
        expect(student_attendance.status).to eq('absent')
        expect(student_attendance.join_time).to_not eq(join_time)
        student_attendance.assign_status("present", join_time)
        expect(student_attendance.status).to eq('present')
        expect(student_attendance.join_time).to eq(join_time)
      end

      it 'overwrites a tardy status with a present' do
        student_attendance = create(:student_attendance, status: :tardy)
        join_time = Time.parse("2021-12-17T16:00:00Z")
        expect(student_attendance.status).to eq('tardy')
        expect(student_attendance.join_time).to_not eq(join_time)
        student_attendance.assign_status("present", join_time)
        expect(student_attendance.status).to eq('present')
        expect(student_attendance.join_time).to eq(join_time)
      end

      it 'does not overwrite a present status with a tardy' do
        join_time = Time.parse("2021-12-17T16:15:00Z")
        student_attendance = create(:student_attendance, status: :present, join_time: join_time)
        expect(student_attendance.status).to eq('present')
        expect(student_attendance.join_time).to eq(join_time)
        student_attendance.assign_status("tardy", join_time + 5.minutes)
        expect(student_attendance.status).to eq('present')
        expect(student_attendance.join_time).to eq(join_time)
      end

      it 'does not overwrite a present status with an absent' do
        join_time = Time.parse("2021-12-17T16:15:00Z")
        student_attendance = create(:student_attendance, status: :present, join_time: join_time)
        expect(student_attendance.status).to eq('present')
        expect(student_attendance.join_time).to eq(join_time)
        student_attendance.assign_status("absent", join_time + 35.minutes)
        expect(student_attendance.status).to eq('present')
        expect(student_attendance.join_time).to eq(join_time)
      end

      it 'does not overwrite a tardy status with an absent' do
        join_time = Time.parse("2021-12-17T16:15:00Z")
        student_attendance = create(:student_attendance, status: :tardy, join_time: join_time)
        expect(student_attendance.status).to eq('tardy')
        expect(student_attendance.join_time).to eq(join_time)
        student_attendance.assign_status("absent", join_time + 35.minutes)
        expect(student_attendance.status).to eq('tardy')
        expect(student_attendance.join_time).to eq(join_time)
      end
    end

    xdescribe "time caluclations" do
      # these should be moved to slack thread participant and zoom participant tests
      it 'assigns absent for a student that never joins the meeting' do
        student_attendance = create(:student_attendance)

        join_time = nil
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('absent')
      end

      it 'assigns present if the student is exactly 1 minute late' do
        student_attendance = create(:student_attendance, join_time: nil)
        join_time = Time.parse("2021-12-17T16:01:00Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('present')
      end

      it 'assigns tardy if the student is 1 second past 1 minute late' do
        student_attendance = create(:student_attendance, join_time: nil)
        join_time = Time.parse("2021-12-17T16:01:01Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('tardy')
      end

      it 'assigns tardy if the student is exactly 30 minutes late' do
        student_attendance = create(:student_attendance, join_time: nil)
        join_time = Time.parse("2021-12-17T16:30:00Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('tardy')
      end

      it 'assigns absent if the student is more than 30 minutes late' do
        student_attendance = create(:student_attendance, join_time: nil)
        join_time = Time.parse("2021-12-17T16:30:01Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('absent')
      end
    end
  end
end
