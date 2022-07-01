require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'validations' do
    it {should validate_presence_of :zoom_id}
    it {should validate_uniqueness_of :zoom_id}
  end

  describe 'relationships' do
    it {should belong_to(:turing_module).optional}
    it {should have_many :student_attendances}
    it {should have_many(:attendances).through(:student_attendances)}
  end

  describe 'class methods' do
    describe '::find_or_create_from_participant' do
      let(:participant) do
        {
          "id": "E0WPTrXCQAGkMsvF9rQgQA",
          "user_id": "16778240",
          "name": "Ryan Teske (He/Him)",
          "user_email": "ryanteske@outlook.com",
          "join_time": "2021-12-17T15:48:18Z",
          "leave_time": "2021-12-17T16:21:59Z",
          "duration": 2021,
          "attentiveness_score": "",
          "failover": false,
          "customer_key": ""
        }
      end

      it 'finds the students if they exist' do
        existing_student = Student.create(zoom_id: participant[:id], zoom_email: participant[:user_email], name: participant[:name])
        found_student = Student.find_or_create_from_participant(participant)
        expect(found_student.id).to eq(existing_student.id)
        expect(found_student.name).to eq(existing_student.name)
        expect(found_student.zoom_email).to eq(existing_student.zoom_email)
        expect(found_student.zoom_id).to eq(existing_student.zoom_id)
      end

      it 'creates the student with all their info if they do not exist' do
        found_student = Student.find_or_create_from_participant(participant)
        expect(found_student.name).to eq(participant[:name])
        expect(found_student.zoom_email).to eq(participant[:user_email])
        expect(found_student.zoom_id).to eq(participant[:id])
      end
    end
  end
end
