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
        existing_student = Student.create(zoom_id: participant[:id], name: participant[:name])
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
        expect(found_student.name).to eq(participant[:name])
        expect(found_student.zoom_id).to eq(participant[:id])
        expect(Student.count).to eq(1)
      end
    end
  end

  describe 'instance methods' do
    describe '#best_match' do
      before :each do
        @populi_student1 = PopuliStudent.new('Leo Banos Garcia')
        @populi_student2 = PopuliStudent.new('Anthony C (Anthony) Blackwell Tallent')
        @populi_student3 = PopuliStudent.new('Janice (Lacey) Weaver')
        @populi_student4 = PopuliStudent.new('Anhnhi (Anhnhi) Tran')
        @populi_student5 = PopuliStudent.new('Jake (J) Seymour')
        @populi_student6 = PopuliStudent.new('MIchael (Mike) Cummins')
        @populi_student7 = PopuliStudent.new('Samuel (Sam) Cox')
        @populi_students = [
          @populi_student1,
          @populi_student2,
          @populi_student3,
          @populi_student4,
          @populi_student5,
          @populi_student6,
          @populi_student7
        ]

        @student_1 = create(:student, name: 'Leo BG# BE')
        @student_2 = create(:student, name: 'Anthony B. (He/Him) BE 2210')
        @student_3 = create(:student, name: 'Lacey W (she/her)')
        @student_4 = create(:student, name: 'Anhnhi T# BE')
        @student_5 = create(:student, name: 'J Seymour (he/they) BE')
        @student_6 = create(:student, name: 'Mike C. (he/him) BE')
        @student_7 = create(:student, name: 'Samuel C (He/Him) BE')
      end

      it 'returns the populi student with the best matching name' do
        expect(@student_1.best_match(@populi_students).name).to eq('Leo Banos Garcia')
        expect(@student_2.best_match(@populi_students).name).to eq('Anthony C (Anthony) Blackwell Tallent')
        expect(@student_3.best_match(@populi_students).name).to eq('Janice (Lacey) Weaver')
        expect(@student_4.best_match(@populi_students).name).to eq('Anhnhi (Anhnhi) Tran')
        expect(@student_5.best_match(@populi_students).name).to eq('Jake (J) Seymour')
        expect(@student_6.best_match(@populi_students).name).to eq('MIchael (Mike) Cummins')
        expect(@student_7.best_match(@populi_students).name).to eq('Samuel (Sam) Cox')
      end

      it 'will make a best guess if no name matches' do
        student = create(:student, name: 'Penny Lane')
        expect(student.best_match(@populi_students).name).to eq('Janice (Lacey) Weaver')
      end
    end
  end
end
