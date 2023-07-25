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
    xit '#record' do
      
    end
    
    xit '#rerecord' do
      
    end
    
    xit '#take_participant_attendance' do
      
    end
    
    xit '#take_absentee_attendance' do
      
    end
    
    xit '#update_time(time)' do
      # def update_time(time)
      #   hour = time.split(":").first
      #   minutes = time.split(":").last
      #   new_time = attendance_time.in_time_zone('Mountain Time (US & Canada)').change(hour: hour, min: minutes)
      #   self.update!(attendance_time: new_time)
      # end
      
      # create instance w/ timestamp
      # Update the time of the instance
    end
    
    xit '#count_status(status)' do
      
    end
    
    xit '#transfer_to_populi!(populi_meeting_id)' do
      
    end
  end
end
