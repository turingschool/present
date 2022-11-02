require 'rails_helper'

RSpec.describe StudentAttendance, type: :model do
  describe 'relationships' do
    it {should belong_to :student}
    it {should belong_to :attendance}
  end

  it {should define_enum_for(:status).with_values(present: 0, tardy: 1, absent: 2)}

  describe 'class methods' do
    it '.by_last_name' do
      test_module = create(:turing_module)
      attendance = create(:attendance)
      kevin = Student.new(zoom_id: "E0WXCQAGkMsvF9rQgQA", name: "kevin", zoom_email: " ") # to test that students without last name present are still in returned list
      ryan = Student.new(zoom_id: "E0WPTrXCQAGkMsvF9rQgQA", name: "Ryan Teske (He/Him)", zoom_email: "ryanteske@outlook.com")
      dane = Student.new(zoom_id: "yCdFUkVWSZO2KN5rt1_Evw", name: "Dane Brophy (he/they)# BE", zoom_email: "dbrophy720@gmail.com")
      jamie = Student.new(zoom_id: "Z-b5rLp9QmCAmx1rECjPUA", name: "Jamie Pace (she/her)# BE", zoom_email: "jamiejpace@gmail.com")

      students = [ryan, dane, jamie, kevin]

      test_module.students = students
      attendance.students = students

      ordered_list = attendance.student_attendances.by_last_name

      expect(ordered_list.first.student).to eq(kevin)
      expect(ordered_list.second.student).to eq(dane)
      expect(ordered_list.third.student).to eq(jamie)
      expect(ordered_list.fourth.student).to eq(ryan)
    end

    it ".by_attendance_status" do
      test_module = create(:turing_module)
      attendance = create(:attendance)

      kevin = Student.new(zoom_id: "E0WXCQAGkMsvF9rQgQA", name: "kevin", zoom_email: " ") # to test that students without last name present are still in returned list
      ryan = Student.new(zoom_id: "E0WPTrXCQAGkMsvF9rQgQA", name: "Ryan Teske (He/Him)", zoom_email: "ryanteske@outlook.com")
      dane = Student.new(zoom_id: "yCdFUkVWSZO2KN5rt1_Evw", name: "Dane Brophy (he/they)# BE", zoom_email: "dbrophy720@gmail.com")
      jamie = Student.new(zoom_id: "Z-b5rLp9QmCAmx1rECjPUA", name: "Jamie Pace (she/her)# BE", zoom_email: "jamiejpace@gmail.com")

      students = [ryan, dane, jamie, kevin]
      attendance.student_attendances.create(student: kevin, status: :present)
      attendance.student_attendances.create(student: ryan, status: :absent)
      attendance.student_attendances.create(student: dane, status: :tardy)
      attendance.student_attendances.create(student: jamie, status: :absent)
      
      test_module.students = students
      attendance.students = students
      
      ordered_list = attendance.student_attendances.by_attendance_status
      expect(ordered_list.first.student).to eq(jamie)
      expect(ordered_list.second.student).to eq(ryan)
      expect(ordered_list.third.student).to eq(dane)
      expect(ordered_list.last.student).to eq(kevin)
    end
  end

  describe 'instance methods' do
    describe '#assign_status' do
      it 'assigns the join time' do
        student_attendance = create(:student_attendance, join_time: nil)
        join_time = Time.parse("2021-12-17T15:48:18Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.join_time).to eq(join_time)
      end

      it 'assigns present to a student who joins early' do
        student_attendance = create(:student_attendance, join_time: nil)
        join_time = Time.parse("2021-12-17T15:48:18Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('present')
      end

      it 'assigns absent for a student that never joins the meeting' do
        student_attendance = create(:student_attendance, join_time: nil)
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

      it 'overwrites an absent status with a tardy' do
        student_attendance = create(:student_attendance, status: :absent, join_time: Time.parse("2021-12-17T16:30:01Z"))
        join_time = Time.parse("2021-12-17T16:15:00Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('tardy')
        expect(student_attendance.join_time).to eq(join_time)
      end

      it 'overwrites an absent status with a present' do
        student_attendance = create(:student_attendance, status: :absent, join_time: Time.parse("2021-12-17T16:30:01Z"))
        join_time = Time.parse("2021-12-17T16:00:00Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('present')
        expect(student_attendance.join_time).to eq(join_time)
      end

      it 'overwrites a tardy status with a present' do
        student_attendance = create(:student_attendance, status: :tardy, join_time: Time.parse("2021-12-17T16:15:00Z"))
        join_time = Time.parse("2021-12-17T16:00:00Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('present')
        expect(student_attendance.join_time).to eq(join_time)
      end

      it 'does not overwrite a present status with a tardy' do
        student_attendance = create(:student_attendance, status: :present, join_time: Time.parse("2021-12-17T16:00:00Z"))
        join_time = Time.parse("2021-12-17T16:15:00Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('present')
        expect(student_attendance.join_time).to_not eq(join_time)
      end

      it 'does not overwrite a present status with an absent' do
        student_attendance = create(:student_attendance, status: :present, join_time: Time.parse("2021-12-17T16:00:00Z"))
        join_time = Time.parse("2021-12-17T16:35:00Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('present')
        expect(student_attendance.join_time).to_not eq(join_time)
      end

      it 'does not overwrite a tardy status with an absent' do
        student_attendance = create(:student_attendance, status: :tardy, join_time: Time.parse("2021-12-17T16:15:00Z"))
        join_time = Time.parse("2021-12-17T16:35:00Z")
        start_time = Time.parse("2021-12-17T16:00:00Z")
        student_attendance.assign_status(join_time, start_time)
        expect(student_attendance.status).to eq('tardy')
        expect(student_attendance.join_time).to_not eq(join_time)
      end
    end

    describe '#visitng_student?' do
      it 'returns true if they student has no associated module' do
        mod = create(:turing_module)
        student = create(:student, turing_module: nil)
        attendance = create(:attendance, turing_module: mod)
        student_attendance = create(:student_attendance, student: student, attendance: attendance)
        expect(student_attendance.visiting_student?).to eq(true)
      end

      it 'returns true if they student has is associated with a different module' do
        mod = create(:turing_module)
        other_mod = create(:turing_module)
        attendance = create(:attendance, turing_module: mod)
        student = create(:student, turing_module: other_mod)
        student_attendance = create(:student_attendance, student: student, attendance: attendance)
        expect(student_attendance.visiting_student?).to eq(true)
      end

      it 'returns false if the student is associated with this module' do
        mod = create(:turing_module)
        student = create(:student, turing_module: mod)
        attendance = create(:attendance, turing_module: mod)
        student_attendance = create(:student_attendance, student: student, attendance: attendance)
        expect(student_attendance.visiting_student?).to eq(false)
      end
    end
  end
end
