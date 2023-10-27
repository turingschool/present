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
    it {should have_many(:student_attendance_hours).through(:student_attendances)}
  end
  
  describe 'instance methods' do
    it '#update_time(time) with valid time' do
      #expect the time to update in UTC when given the MDT time (24 hour format)
      original = create(:attendance, attendance_time: "22 Jul 2023 15:00")
      
      expect(original.attendance_time).to eq("Sat, 22 Jul 2023 15:00:00.000000000 UTC +00:00")
      
      original.update_time("12:00")
      
      expect(original.attendance_time).to eq("Sat, 22 Jul 2023 18:00:00.000000000 UTC +00:00")
    end
    
    it '#update_time(time) with invalid time' do
      #returns an error when an invalid time is given
      original = create(:attendance, attendance_time: "22 Jul 2023 15:00")
      
      expect(original.attendance_time).to eq("Sat, 22 Jul 2023 15:00:00.000000000 UTC +00:00")
      
      expect { original.update_time("25:00") }.to raise_error(ArgumentError, "Invalid time format. Hour and minutes should be in the range 00:00 to 23:59.")
    end

    describe "#record_duration_from_presence_checks!" do
      before :each do
        @test_module = create(:turing_module)
        current_time = Time.now
        @attendance = create(:slack_attendance, attendance_time: current_time - 2.hours, end_time: current_time - 1.hour)
        students = create_list(:student, 4, turing_module: @test_module)
        @absent_student, @flaky_student, @present_student, @error_student = students
       
        @absent_student_attendance = create(:student_attendance, student: @absent_student, attendance: @attendance, status: :absent, duration: 0)
        @flaky_student_attendance = create(:student_attendance, student: @flaky_student, attendance: @attendance, status: :tardy, duration: 0)
        @present_student_attendance = create(:student_attendance, student: @present_student, attendance: @attendance, status: :present, duration: 0)
        @error_student_attendance = create(:student_attendance, student: @error_student, attendance: @attendance, status: :absent, duration: 0)
        12.times do |i|
          check_time = @attendance.attendance_time + 2.minutes + (5.minutes * i) # Checks happen every 5 minutes starting 2 minutes past attendance time
          flaky_presence = i % 5 == 0 ? :active : :away # The flaky student is active for every 5th check starting with the first one
          create(:slack_presence_check, student: @flaky_student, check_time: check_time, presence: flaky_presence)
          create(:slack_presence_check, student: @absent_student, check_time: check_time, presence: :away) # absent student is never active
          create(:slack_presence_check, student: @present_student, check_time: check_time, presence: :active) # present student is always active
        end
      end

      it "increases the duration for the present student" do
        expect { @attendance.record_duration_from_presence_checks! }
          .to change { @present_student_attendance.reload.duration }
          .to 60
      end

      it "increases the duration for the flaky student" do
        # 1 of the fifteen minutes blocks does not have any active checks for the flaky student
        expect { @attendance.record_duration_from_presence_checks! }
          .to change { @flaky_student_attendance.reload.duration }
          .to 45
      end

      it "doesn't increase duration for the absent student" do
        expect { @attendance.record_duration_from_presence_checks! }
          .to_not change { @absent_student_attendance.reload.duration }
      end
      
      it "doesn't increase duration for the error student" do
        # We didn't record any presence data for this student, so their duration should not change
        expect { @attendance.record_duration_from_presence_checks! }
          .to_not change { @error_student_attendance.reload.duration }
      end

      it "resets the duration to 0 if the duration was previously recorded" do
        @attendance.record_duration_from_presence_checks!

        expect { @attendance.record_duration_from_presence_checks! }
          .to_not change { @present_student_attendance.reload.duration }
      end

      it "presence checks that fall exactly in between two 15 minute chunks only count for the later chunk" do
        # The flaky student does not have any active checks for the third 15 minute chunk

        # This presence check falls exactly on the end of the third 15 minute chunk
        # This will count as a check for the fourth chunk and not the third
        create(:slack_presence_check, student: @flaky_student, check_time: @attendance.attendance_time + 45.minutes, presence: :active)

        expect { @attendance.record_duration_from_presence_checks! }
          .to change { @flaky_student_attendance.reload.duration }
          .to 45

        # This presence check falls exactly on the end of the second 15 minute chunk
        # This will count as a check for the third chunk, giving the flaky student the 15 minutes they were missing without this check
        create(:slack_presence_check, student: @flaky_student, check_time: @attendance.attendance_time + 30.minutes, presence: :active) 
        
        expect { @attendance.record_duration_from_presence_checks! }
          .to change { @flaky_student_attendance.reload.duration }
          .to 60
      end

      it 'does not include any presence data from before the start time' do
        create(:slack_presence_check, student: @absent_student, check_time: @attendance.attendance_time - 1.second, presence: :active)

        expect { @attendance.record_duration_from_presence_checks! }
        .to_not change { @absent_student_attendance.reload.duration }
      end

      it "includes presence data at that falls at exactly the start time" do
        create(:slack_presence_check, student: @absent_student, check_time: @attendance.attendance_time, presence: :active)

        expect { @attendance.record_duration_from_presence_checks! }
          .to change { @absent_student_attendance.reload.duration }
          .to 15
      end

      it 'excludes presence data that falls at exactly the end time' do
        create(:slack_presence_check, student: @absent_student, check_time: @attendance.end_time, presence: :active)

        expect { @attendance.record_duration_from_presence_checks! }
        .to_not change { @absent_student_attendance.reload.duration }
      end

      it "will shorten the last 15 minute chunk if the attendance time is not divisible by 15" do
        @attendance.update(end_time: @attendance.end_time + 4.minutes) # The last chunk of time should only be 4 minutes
        # this presence check falls in the last chunk, so the student should get credit for the length of that chunk
        create(:slack_presence_check, student: @absent_student, check_time: @attendance.end_time - 2.minutes, presence: :active) 

        expect { @attendance.record_duration_from_presence_checks! }
          .to change { @absent_student_attendance.reload.duration }
          .to 4
      end

      it "will not count checks that fall within a 15 minute chunk but are past the end time" do
        @attendance.update(end_time: @attendance.end_time + 4.minutes) # The last chunk of time should only be 4 minutes
        # this presence check is after the end time, so the student gets no duration
        create(:slack_presence_check, student: @absent_student, check_time: @attendance.end_time + 5.minutes, presence: :active)

        expect { @attendance.record_duration_from_presence_checks! }
          .to_not change { @absent_student_attendance.reload.duration }
      end
    end
    
    xit '#record' do
      # tests take_participant_attendance and take_absentee_attendance
    end
    
    xit '#rerecord' do
      
    end
    
    xit '#take_participant_attendance' do
      
    end
    
    xit '#take_absentee_attendance' do
      
    end
    
    xit '#count_status(status)' do
      
    end
    
    xit '#transfer_to_populi!(populi_meeting_id)' do
      
    end
  end
end
