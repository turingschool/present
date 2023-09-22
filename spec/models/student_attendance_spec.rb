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
    xdescribe '#record_status_for_participant!' do
      before :each do
        @join_time = "2021-12-17T15:48:18Z"
        @different_join_time = "2021-11-11T11:11:18Z"
        @student_attendance = create(:student_attendance)
      end

      it 'assigns a present status' do
        participant = ZoomParticipant.new({join_time: @join_time, attendance_status: "present"})  

        @student_attendance.record_status_for_participant!(participant)

        expect(@student_attendance.status).to eq("present")
        expect(@student_attendance.join_time).to eq(@join_time)
      end
      
      it 'assigns a tardy status' do
        participant = ZoomParticipant.new({join_time: @join_time, attendance_status: "tardy"})  

        @student_attendance.record_status_for_participant!(participant)

        expect(@student_attendance.status).to eq("tardy")
        expect(@student_attendance.join_time).to eq(@join_time)
      end
      
      it 'assigns an absent status' do
        participant = ZoomParticipant.new({join_time: @join_time, attendance_status: "absent"})  

        @student_attendance.record_status_for_participant!(participant)

        expect(@student_attendance.status).to eq("absent")
        expect(@student_attendance.join_time).to eq(@join_time)
      end

      it 'overwrites an absent status with a tardy' do
        @student_attendance.update(status: :absent)
        participant = ZoomParticipant.new({join_time: @join_time, attendance_status: "tardy"})  

        expect(@student_attendance.status).to eq('absent')
        expect(@student_attendance.join_time).to_not eq(@join_time)

        @student_attendance.record_status_for_participant!(participant)

        expect(@student_attendance.status).to eq('tardy')
        expect(@student_attendance.join_time).to eq(@join_time)
      end

      it 'overwrites an absent status with a present' do
        @student_attendance.update(status: :absent)
        participant = ZoomParticipant.new({join_time: @join_time, attendance_status: "present"})  

        expect(@student_attendance.status).to eq('absent')
        expect(@student_attendance.join_time).to_not eq(@join_time)

        @student_attendance.record_status_for_participant!(participant)
        
        expect(@student_attendance.status).to eq('present')
        expect(@student_attendance.join_time).to eq(@join_time)
      end

      it 'overwrites a tardy status with a present' do
        @student_attendance.update(status: :tardy)
        participant = ZoomParticipant.new({join_time: @join_time, attendance_status: "present"})  

        expect(@student_attendance.status).to eq('tardy')
        expect(@student_attendance.join_time).to_not eq(@join_time)

        @student_attendance.record_status_for_participant!(participant)
        
        expect(@student_attendance.status).to eq('present')
        expect(@student_attendance.join_time).to eq(@join_time)
      end

      it 'does not overwrite a present status with a tardy' do
        @student_attendance.update(status: :present, join_time: @join_time)
        participant = ZoomParticipant.new({join_time: @different_join_time, attendance_status: "tardy"})  

        expect(@student_attendance.status).to eq('present')
        expect(@student_attendance.join_time).to eq(@join_time)

        @student_attendance.record_status_for_participant!(participant)
        
        expect(@student_attendance.status).to eq('present')
        expect(@student_attendance.join_time).to eq(@join_time)
      end

      it 'does not overwrite a present status with an absent' do
        @student_attendance.update(status: :present, join_time: @join_time)
        participant = ZoomParticipant.new({join_time: @different_join_time, attendance_status: "absent"})  

        expect(@student_attendance.status).to eq('present')
        expect(@student_attendance.join_time).to eq(@join_time)

        @student_attendance.record_status_for_participant!(participant)
        
        expect(@student_attendance.status).to eq('present')
        expect(@student_attendance.join_time).to eq(@join_time)
      end

      it 'does not overwrite a tardy status with an absent' do
        @student_attendance.update(status: :tardy, join_time: @join_time)
        participant = ZoomParticipant.new({join_time: @different_join_time, attendance_status: "absent"})  

        expect(@student_attendance.status).to eq('tardy')
        expect(@student_attendance.join_time).to eq(@join_time)

        @student_attendance.record_status_for_participant!(participant)
        
        expect(@student_attendance.status).to eq('tardy')
        expect(@student_attendance.join_time).to eq(@join_time)
      end
    end

    describe "time calculations" do
      # these should be moved to slack thread participant and zoom participant tests
      xit 'assigns absent for a student that never joins the meeting' do
        student_attendance = create(:student_attendance)

        join_time = nil
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('absent')
      end

      xit 'assigns present if the student is exactly 1 minute late' do
        student_attendance = create(:student_attendance, join_time: nil)
        join_time = Time.parse("2021-12-17T16:01:00Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('present')
      end

      xit 'assigns tardy if the student is 1 second past 1 minute late' do
        student_attendance = create(:student_attendance, join_time: nil)
        join_time = Time.parse("2021-12-17T16:01:01Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('tardy')
      end

      xit 'assigns tardy if the student is exactly 30 minutes late' do
        student_attendance = create(:student_attendance, join_time: nil)
        join_time = Time.parse("2021-12-17T16:30:00Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('tardy')
      end

      xit 'assigns absent if the student is more than 30 minutes late' do
        student_attendance = create(:student_attendance, join_time: nil)
        join_time = Time.parse("2021-12-17T16:30:01Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('absent')
      end
    end
  end
end
