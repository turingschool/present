require 'rails_helper'

RSpec.describe SlackThread do
  it {should have_one :attendance}
  it {should have_one(:turing_module).through(:attendance)}
  it {should have_one(:inning).through(:turing_module)}

  describe "Instance Methods" do
    describe "#record_duration_from_presence_checks!" do
      context "class is 3 hours long" do
        before :each do
          @test_module = create(:turing_module)
          current_time = Time.now
          @attendance = create(:slack_attendance, attendance_time: current_time - 4.hours, end_time: current_time - 1.hour)
          @slack_thread = @attendance.meeting
          students = create_list(:student, 4, turing_module: @test_module)
          @absent_student, @flaky_student, @present_student, @error_student = students
          
          @absent_student_attendance = create(:student_attendance, student: @absent_student, attendance: @attendance, status: :absent, duration: 0)
          @flaky_student_attendance = create(:student_attendance, student: @flaky_student, attendance: @attendance, status: :tardy, duration: 0)
          @present_student_attendance = create(:student_attendance, student: @present_student, attendance: @attendance, status: :present, duration: 0)
          # This is an error because we don't have any presence data for this student
          @error_student_attendance = create(:student_attendance, student: @error_student, attendance: @attendance, status: :absent, duration: 0)
          36.times do |i|
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
            .to 180
        end

        it "increases the duration for the flaky student" do
          # 1 of the fifteen minutes blocks does not have any active checks for the flaky student
          expect { @slack_thread.record_duration_from_presence_checks! }
            .to change { @flaky_student_attendance.reload.duration }
            .to 120
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
            .to 120

          # This presence check falls exactly on the end of the second 15 minute chunk
          # This will count as a check for the third chunk, giving the flaky student the 15 minutes they were missing in the first hour without this check
          create(:slack_presence_check, student: @flaky_student, check_time: @attendance.attendance_time + 30.minutes, presence: :active) 
          
          expect { @slack_thread.record_duration_from_presence_checks! }
            .to change { @flaky_student_attendance.reload.duration }
            .to 135
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

        it "creates student_attendance_hours for the present student" do
          @slack_thread.record_duration_from_presence_checks!
          
          expect(@present_student.student_attendance_hours.count).to eq(3)
          expect(@present_student.student_attendance_hours.first.duration).to eq(60)
          expect(@present_student.student_attendance_hours.first.status).to eq("present")
          expect(@present_student.student_attendance_hours.second.duration).to eq(60)
          expect(@present_student.student_attendance_hours.second.status).to eq("present")
          expect(@present_student.student_attendance_hours.third.duration).to eq(60)
          expect(@present_student.student_attendance_hours.third.status).to eq("present")
        end

        it "creates student_attendance_hours for the absent student" do
          @slack_thread.record_duration_from_presence_checks!

          expect(@absent_student.student_attendance_hours.count).to eq(3)
          expect(@absent_student.student_attendance_hours.first.duration).to eq(0)
          expect(@absent_student.student_attendance_hours.first.status).to eq("absent")
          expect(@absent_student.student_attendance_hours.second.duration).to eq(0)
          expect(@absent_student.student_attendance_hours.second.status).to eq("absent")
          expect(@absent_student.student_attendance_hours.third.duration).to eq(0)
          expect(@absent_student.student_attendance_hours.third.status).to eq("absent")
        end

        it "creates student_attendance_hours for the error student" do
          @slack_thread.record_duration_from_presence_checks!

          expect(@error_student.student_attendance_hours.count).to eq(3)
          expect(@error_student.student_attendance_hours.first.duration).to eq(0)
          expect(@error_student.student_attendance_hours.first.status).to eq("absent")
          expect(@error_student.student_attendance_hours.second.duration).to eq(0)
          expect(@error_student.student_attendance_hours.second.status).to eq("absent")
          expect(@error_student.student_attendance_hours.third.duration).to eq(0)
          expect(@error_student.student_attendance_hours.third.status).to eq("absent")
        end

        it "creates student_attendance_hours for the flaky student" do
          @slack_thread.record_duration_from_presence_checks!

          expect(@flaky_student.student_attendance_hours.count).to eq(3)
          expect(@flaky_student.student_attendance_hours.first.duration).to eq(45)
          expect(@flaky_student.student_attendance_hours.first.status).to eq("absent")
          expect(@flaky_student.student_attendance_hours.second.duration).to eq(30)
          expect(@flaky_student.student_attendance_hours.second.status).to eq("absent")
          expect(@flaky_student.student_attendance_hours.third.duration).to eq(45)
          expect(@flaky_student.student_attendance_hours.third.status).to eq("absent")
        end

        it 'will overwrite previous attendance hours' do
          @slack_thread.record_duration_from_presence_checks!

          expect(@flaky_student.student_attendance_hours.count).to eq(3)
          expect(@flaky_student.student_attendance_hours.first.duration).to eq(45)
          expect(@flaky_student.student_attendance_hours.first.status).to eq("absent")

          # This new presence check gives the flaky student credit for the 3rd 15 minute chunk which they were previously missing
          create(:slack_presence_check, student: @flaky_student, check_time: @attendance.attendance_time + 35.minutes, presence: :active)

          @slack_thread.record_duration_from_presence_checks!

          expect(@flaky_student.student_attendance_hours.count).to eq(3) # No new attendance hours should be created
          expect(@flaky_student.student_attendance_hours.first.duration).to eq(60) # Previous data should be overwritten
          expect(@flaky_student.student_attendance_hours.first.status).to eq("present") # Previous data should be overwritten
        end

        it 'marks the slack thread presence check as complete' do
          expect(@slack_thread.presence_check_complete).to_not eq(true)
          @slack_thread.record_duration_from_presence_checks!
          @slack_thread.reload
          expect(@slack_thread.presence_check_complete).to eq(true)
        end
      end  

      context "class is 1.5 hours long" do
        before :each do
          @test_module = create(:turing_module)
          current_time = Time.now
          @attendance = create(:slack_attendance, attendance_time: current_time - 2.hours, end_time: current_time - 30.minutes)
          @slack_thread = @attendance.meeting
          students = create_list(:student, 4, turing_module: @test_module)
          @absent_student, @flaky_student, @present_student, @error_student = students
          
          @absent_student_attendance = create(:student_attendance, student: @absent_student, attendance: @attendance, status: :absent, duration: 0)
          @flaky_student_attendance = create(:student_attendance, student: @flaky_student, attendance: @attendance, status: :tardy, duration: 0)
          @present_student_attendance = create(:student_attendance, student: @present_student, attendance: @attendance, status: :present, duration: 0)
          # This is an error because we don't have any presence data for this student
          @error_student_attendance = create(:student_attendance, student: @error_student, attendance: @attendance, status: :absent, duration: 0)
          18.times do |i|
            check_time = @attendance.attendance_time + 2.minutes + (5.minutes * i) # Checks happen every 5 minutes starting 2 minutes past attendance time
            flaky_presence = i % 5 == 0 ? :active : :away # The flaky student is active for every 5th check starting with the first one
            create(:slack_presence_check, student: @flaky_student, check_time: check_time, presence: flaky_presence)
            create(:slack_presence_check, student: @absent_student, check_time: check_time, presence: :away) # absent student is never active
            create(:slack_presence_check, student: @present_student, check_time: check_time, presence: :active) # present student is always active
          end
        end

        it 'will use the 50/60 minute ratio to calculate presence for a half hour' do
          @slack_thread.record_duration_from_presence_checks!

          expect(@present_student.student_attendance_hours.count).to eq(2)
          expect(@present_student.student_attendance_hours.first.duration).to eq(60)
          expect(@present_student.student_attendance_hours.first.status).to eq("present")
          expect(@present_student.student_attendance_hours.second.duration).to eq(30)
          expect(@present_student.student_attendance_hours.first.status).to eq("present")
          
          expect(@flaky_student.student_attendance_hours.count).to eq(2)
          expect(@flaky_student.student_attendance_hours.first.duration).to eq(45)
          expect(@flaky_student.student_attendance_hours.first.status).to eq("absent")
          expect(@flaky_student.student_attendance_hours.second.duration).to eq(15)
          expect(@flaky_student.student_attendance_hours.second.status).to eq("absent")

          expect(@absent_student.student_attendance_hours.count).to eq(2)
          expect(@absent_student.student_attendance_hours.first.duration).to eq(0)
          expect(@absent_student.student_attendance_hours.first.status).to eq("absent")
          expect(@absent_student.student_attendance_hours.second.duration).to eq(0)
          expect(@absent_student.student_attendance_hours.second.status).to eq("absent")
          
          expect(@error_student.student_attendance_hours.count).to eq(2)
          expect(@error_student.student_attendance_hours.first.duration).to eq(0)
          expect(@error_student.student_attendance_hours.first.status).to eq("absent")
          expect(@error_student.student_attendance_hours.second.duration).to eq(0)
          expect(@error_student.student_attendance_hours.second.status).to eq("absent")
        end
      end

      context "class is 54 minutes long" do
        before :each do
          @test_module = create(:turing_module)
          current_time = Time.now
          @attendance = create(:slack_attendance, attendance_time: current_time - 54.minutes, end_time: current_time)
          @slack_thread = @attendance.meeting
          students = create_list(:student, 4, turing_module: @test_module)
          @absent_student, @flaky_student, @present_student, @error_student = students
          
          @absent_student_attendance = create(:student_attendance, student: @absent_student, attendance: @attendance, status: :absent, duration: 0)
          @flaky_student_attendance = create(:student_attendance, student: @flaky_student, attendance: @attendance, status: :tardy, duration: 0)
          @present_student_attendance = create(:student_attendance, student: @present_student, attendance: @attendance, status: :present, duration: 0)
          # This is an error because we don't have any presence data for this student
          @error_student_attendance = create(:student_attendance, student: @error_student, attendance: @attendance, status: :absent, duration: 0)
          4.times do |i|
            check_time = @attendance.attendance_time + 2.minutes + (15.minutes * i)
            create(:slack_presence_check, student: @absent_student, check_time: check_time, presence: :away) # absent student is never active
            create(:slack_presence_check, student: @present_student, check_time: check_time, presence: :active) # present student is always active
            unless i == 3 # Flaky student is not present for the last 15 minute chunk
              create(:slack_presence_check, student: @flaky_student, check_time: check_time, presence: :active)
            end
          end
        end

        it "a student who is present for 45/54 minutes meets the 50/60 minute threshold" do
          @slack_thread.record_duration_from_presence_checks!
          
          expect(@flaky_student.student_attendance_hours.count).to eq(1)
          expect(@flaky_student.student_attendance_hours.first.duration).to eq(45)
          expect(@flaky_student.student_attendance_hours.first.status).to eq("present")
        end

        it "creates student_attendance_hours for the present student" do
          @slack_thread.record_duration_from_presence_checks!
          
          expect(@present_student.student_attendance_hours.count).to eq(1)
          expect(@present_student.student_attendance_hours.first.duration).to eq(54)
          expect(@present_student.student_attendance_hours.first.status).to eq("present")
        end

        it "creates student_attendance_hours for the absent student" do
          @slack_thread.record_duration_from_presence_checks!

          expect(@absent_student.student_attendance_hours.count).to eq(1)
          expect(@absent_student.student_attendance_hours.first.duration).to eq(0)
          expect(@absent_student.student_attendance_hours.first.status).to eq("absent")
        end

        it "creates student_attendance_hours for the error student" do
          @slack_thread.record_duration_from_presence_checks!

          expect(@error_student.student_attendance_hours.count).to eq(1)
          expect(@error_student.student_attendance_hours.first.duration).to eq(0)
          expect(@error_student.student_attendance_hours.first.status).to eq("absent")
        end
      end
    end
  end

  describe 'class methods' do
    describe '.from_message_link' do
      before :each do 
        @channel_id = "C02HRH7MF5K"
        @timestamp = "1672861516089859"
        @slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

        stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=#{@channel_id}&timestamp=#{@timestamp}") \
        .to_return(body: File.read('spec/fixtures/slack/message_replies_response.json'))
      end

      it 'creates the slack thread' do
        slack_thread = SlackThread.from_message_link(@slack_url)
        expect(slack_thread.channel_id).to eq(@channel_id)
        expect(slack_thread.sent_timestamp).to eq(@timestamp)
        expect(slack_thread.start_time).to eq(DateTime.parse("Wed, 30 Nov 2022 20:00:59.999000000 UTC +00:00"))
        expect(slack_thread.presence_check_complete).to eq(false)
      end

      it 'will not duplicate slack thread records with the same channel id and sent timestamp' do
        SlackThread.from_message_link(@slack_url)
        SlackThread.from_message_link(@slack_url)
        expect(SlackThread.count).to eq(1)
      end

      it 'will update existing records if any non unique fields changed' do
        slack_thread = SlackThread.from_message_link(@slack_url)
        slack_thread.update!(presence_check_complete: true)
        slack_thread = SlackThread.from_message_link(@slack_url)
        expect(slack_thread.presence_check_complete).to eq(false)
        expect(SlackThread.count).to eq(1)
      end
    end
  end
end