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
    it '#update_time(time)' do
      #expect the time to update in UTC when given the MDT time (24 hour format)
      original = create(:attendance, attendance_time: "22 Jul 2023 15:00")
      
      expect(original.attendance_time).to eq("Sat, 22 Jul 2023 15:00:00.000000000 UTC +00:00")
      
      original.update_time("12:00")
      
      expect(original.attendance_time).to eq("Sat, 22 Jul 2023 18:00:00.000000000 UTC +00:00")
    end
    
    xit '#record' do
      
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
