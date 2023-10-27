require 'rails_helper'

RSpec.describe SlackThread do
  it {should have_one :attendance}
  it {should have_one(:turing_module).through(:attendance)}

  describe "Instance Methods" do
    describe "#record_duration_from_presence_checks!" do
      before :each do
        @test_module = create(:turing_module)
        current_time = Time.now
        @attendance = create(:slack_attendance, attendance_time: current_time - 2.hours, end_time: current_time - 1.hour)
        @slack_thread = @attendance.meeting
        students = create_list(:student, 4, turing_module: @test_module)
        @absent_student, @flaky_student, @present_student, @error_student = students
        
        @absent_student_attendance = create(:student_attendance, student: @absent_student, attendance: @attendance, status: :absent, duration: 0)
        @flaky_student_attendance = create(:student_attendance, student: @flaky_student, attendance: @attendance, status: :tardy, duration: 0)
        @present_student_attendance = create(:student_attendance, student: @present_student, attendance: @attendance, status: :present, duration: 0)
        # This is an error because we don't have any presence data for this student
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
        expect { @slack_thread.record_duration_from_presence_checks! }
          .to change { @present_student_attendance.reload.duration }
          .to 60
      end

      it "increases the duration for the flaky student" do
        # 1 of the fifteen minutes blocks does not have any active checks for the flaky student
        expect { @slack_thread.record_duration_from_presence_checks! }
          .to change { @flaky_student_attendance.reload.duration }
          .to 45
      end

      it "doesn't increase duration for the absent student" do
        expect { @slack_thread.record_duration_from_presence_checks! }
          .to_not change { @absent_student_attendance.reload.duration }
      end
      
      it "doesn't increase duration for the error student" do
        # We didn't record any presence data for this student, so their duration should not change
        expect { @slack_thread.record_duration_from_presence_checks! }
          .to_not change { @error_student_attendance.reload.duration }
      end

      it "resets the duration to 0 if the duration was previously recorded" do
        @slack_thread.record_duration_from_presence_checks!

        expect { @slack_thread.record_duration_from_presence_checks! }
          .to_not change { @present_student_attendance.reload.duration }
      end

      it "presence checks that fall exactly in between two 15 minute chunks only count for the later chunk" do
        # The flaky student does not have any active checks for the third 15 minute chunk

        # This presence check falls exactly on the end of the third 15 minute chunk
        # This will count as a check for the fourth chunk and not the third
        create(:slack_presence_check, student: @flaky_student, check_time: @attendance.attendance_time + 45.minutes, presence: :active)

        expect { @slack_thread.record_duration_from_presence_checks! }
          .to change { @flaky_student_attendance.reload.duration }
          .to 45

        # This presence check falls exactly on the end of the second 15 minute chunk
        # This will count as a check for the third chunk, giving the flaky student the 15 minutes they were missing without this check
        create(:slack_presence_check, student: @flaky_student, check_time: @attendance.attendance_time + 30.minutes, presence: :active) 
        
        expect { @slack_thread.record_duration_from_presence_checks! }
          .to change { @flaky_student_attendance.reload.duration }
          .to 60
      end

      it 'does not include any presence data from before the start time' do
        create(:slack_presence_check, student: @absent_student, check_time: @attendance.attendance_time - 1.second, presence: :active)

        expect { @slack_thread.record_duration_from_presence_checks! }
        .to_not change { @absent_student_attendance.reload.duration }
      end

      it "includes presence data at that falls at exactly the start time" do
        create(:slack_presence_check, student: @absent_student, check_time: @attendance.attendance_time, presence: :active)

        expect { @slack_thread.record_duration_from_presence_checks! }
          .to change { @absent_student_attendance.reload.duration }
          .to 15
      end

      it 'excludes presence data that falls at exactly the end time' do
        create(:slack_presence_check, student: @absent_student, check_time: @attendance.end_time, presence: :active)

        expect { @slack_thread.record_duration_from_presence_checks! }
        .to_not change { @absent_student_attendance.reload.duration }
      end

      it "will shorten the last 15 minute chunk if the attendance time is not divisible by 15" do
        @attendance.update(end_time: @attendance.end_time + 4.minutes) # The last chunk of time should only be 4 minutes
        # this presence check falls in the last chunk, so the student should get credit for the length of that chunk
        create(:slack_presence_check, student: @absent_student, check_time: @attendance.end_time - 2.minutes, presence: :active) 

        expect { @slack_thread.record_duration_from_presence_checks! }
          .to change { @absent_student_attendance.reload.duration }
          .to 4
      end

      it "will not count checks that fall within a 15 minute chunk but are past the end time" do
        @attendance.update(end_time: @attendance.end_time + 4.minutes) # The last chunk of time should only be 4 minutes
        # this presence check is after the end time, so the student gets no duration
        create(:slack_presence_check, student: @absent_student, check_time: @attendance.end_time + 5.minutes, presence: :active)

        expect { @slack_thread.record_duration_from_presence_checks! }
          .to_not change { @absent_student_attendance.reload.duration }
      end

      it "creates student_attendance_hours" do
        @slack_thread.record_duration_from_presence_checks!
        
        expect(@present_student.student_attendance_hours.count).to eq(1)
        expect(@present_student.student_attendance_hours.duration).to eq(60)
        expect(@present_student.student_attendance_hours.status).to eq("present")
        
        expect(@absent_student.student_attendance_hours.count).to eq(1)
        expect(@absent_student.student_attendance_hours.duration).to eq(0)
        expect(@absent_student.student_attendance_hours.status).to eq("absent")
        
        expect(@error_student.student_attendance_hours.count).to eq(1)
        expect(@error_student.student_attendance_hours.duration).to eq(0)
        expect(@error_student.student_attendance_hours.status).to eq("absent")
        
        expect(@flaky_student.student_attendance_hours.count).to eq(1)
        expect(@flaky_student.student_attendance_hours.duration).to eq(45)
        expect(@flaky_student.student_attendance_hours.status).to eq("absent")
      end

      it 'can span multiple hours' do

      end
    end  
  end
end