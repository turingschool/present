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
    describe '::find_or_create_from_participant' do
      let(:participant) do
        ZoomParticipant.new("Ryan Teske (He/Him)", "E0WPTrXCQAGkMsvF9rQgQA", "2021-12-17T15:48:18Z")
      end

      it 'finds the students if they exist' do
        existing_student = Student.create(zoom_id: participant.id, name: participant.name)
        expect(Student.count).to eq(1)
        found_student = Student.find_or_create_from_participant(participant)
        expect(found_student.id).to eq(existing_student.id)
        expect(found_student.name).to eq(existing_student.name)
        expect(found_student.zoom_id).to eq(existing_student.zoom_id)
        expect(Student.count).to eq(1)
      end

      it 'creates the student with all their info if they do not exist' do
        expect(Student.count).to eq(0)
        found_student = Student.find_or_create_from_participant(participant)
        expect(found_student.name).to eq(participant.name)
        expect(found_student.zoom_id).to eq(participant.id)
        expect(Student.count).to eq(1)
      end
    end
  end
end
