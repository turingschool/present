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
  end 
end
