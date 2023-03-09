require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'validations' do
    it {should validate_uniqueness_of :zoom_id}
  end

  describe 'relationships' do
    it {should belong_to(:turing_module).optional}
    it {should have_many :student_attendances}
    it {should have_many(:attendances).through(:student_attendances)}
  end

  describe 'class methods' do
    describe '::have_slack_ids' do 
      it 'returns true if some students have slack ids' do 
        create_list(:student, 3)
        create_list(:student, 2, slack_id: nil)
        
        expect(Student.have_slack_ids).to eq true
      end 
      
      it 'returns false if no students have slack ids' do 
        create_list(:student, 5, slack_id: nil)
        
        expect(Student.have_slack_ids).to eq false
      end 
    end 

    describe '::have_zoom_ids' do 
      it 'returns true if some students have zoom ids' do 
        create_list(:student, 3)
        create_list(:student, 2, zoom_id: nil)
        
        expect(Student.have_zoom_ids).to eq true
      end 
      
      it 'returns false if no students have zoom ids' do 
        create_list(:student, 5, zoom_id: nil)
        
        expect(Student.have_zoom_ids).to eq false
      end 
    end 
  end
end
