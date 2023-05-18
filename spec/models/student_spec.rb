require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_uniqueness_of(:slack_id).scoped_to(:turing_module_id)}
  end
  
  describe 'relationships' do
    it {should belong_to(:turing_module)}
    it {should have_many :student_attendances}
    it {should have_many(:attendances).through(:student_attendances)}
    it {should have_many(:zoom_aliases)}
    it {should have_many(:slack_presence_checks)}
  end

  describe 'class methods' do
    describe '::have_slack_ids' do 
      it 'returns true if some students have slack ids' do 
        create_list(:student, 3)
        create_list(:setup_student, 2)
        
        expect(Student.have_slack_ids).to eq true
      end 
      
      it 'returns false if no students have slack ids' do 
        create_list(:student, 5, slack_id: nil)
        
        expect(Student.have_slack_ids).to eq false
      end 
    end 

    describe '::have_zoom_aliases?' do 
      it 'returns true if some students have zoom ids' do 
        create_list(:student, 3)
        student = create(:student)
        create(:zoom_alias, student: student)
        
        expect(Student.have_zoom_aliases?).to eq true
      end 
      
      it 'returns false if no students have zoom ids' do 
        students = create_list(:student, 5)
        expect(Student.have_zoom_aliases?).to eq false
      end 
    end 
  end
end
