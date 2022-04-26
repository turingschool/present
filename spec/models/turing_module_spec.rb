require 'rails_helper'

RSpec.describe TuringModule, type: :model do
  describe 'relationships' do
    it { should belong_to :inning }
    it { should have_many :attendances }
    it { should have_one :google_sheet }
    it { should have_many :students }
  end

  it { should validate_presence_of :program }
  it { should validate_numericality_of(:module_number).is_greater_than_or_equal_to(1) }
  it { should validate_numericality_of(:module_number).is_less_than_or_equal_to(4) }
  it { should validate_numericality_of(:module_number).only_integer }
  it { should define_enum_for(:program).with_values(([:FE, :BE, :Combined])) }
  it { should validate_inclusion_of(:calendar_integration).in_array([true, false]) }


  describe 'instance methods' do
    describe '#name' do
      it 'returns a combo of the module number and program' do
        test_module = create(:turing_module, program: :FE, module_number: 3)
        expect(test_module.name).to eq('FE Mod 3')
      end
    end

    describe '#create_students_from_participants' do

      let(:participants){
        [
          {
            :id=>"16778240",
            :name=>"Ryan Teske (He/Him)",
            :user_email=>"ryanteske@outlook.com",
          },
          {
            :id=>"16779264",
            :name=>"Isika P (she/her# BE)",
            :user_email=>"",
          },
          {
            :id=>"16780288",
            :name=>"Natalia ZV (she/her)# FE",
            :user_email=>"nzamboniv@gmail.com",
          },
          {
            :id=>"16781312",
            :name=>"Jamie P (she/her)# BE",
            :user_email=>"jamiejpace@gmail.com",
          },
          {
            :id=>"16782336",
            :name=>"",
            :user_email=>"",
          }
        ]
      }

      it 'creates a student for each unique participant' do
        test_module = create(:fe1)
        test_module.create_students_from_participants(participants)
        expect(test_module.students.length).to eq(participants.length)
        all_participants_created = participants.all? do |participant|
          test_module.students.any? do |student|
            student.name == participant[:name] &&
            student.zoom_email == participant[:user_email] &&
            student.zoom_id == participant[:id]
          end
        end
        expect(all_participants_created).to eq(true)
      end

      it 'can create a participant even if it is missing a name and email' do
        test_module = create(:fe1)
        test_module.create_students_from_participants(participants)
        no_name = test_module.students.find do |student|
          student.zoom_id == "16782336"
        end
        expect(no_name.name).to eq("")
        expect(no_name.zoom_email).to eq("")
      end

      it 'will not create a duplicate student with the same Zoom id' do
        duplicate_participant = participants.last.dup
        participants << duplicate_participant
        test_module = create(:fe1)
        test_module.create_students_from_participants(participants)
        test_module.reload
        expect(test_module.students.length).to eq(participants.length - 1)
        num_duplicates = test_module.students.count do |student|
          student.zoom_id == duplicate_participant[:id]
        end
        expect(num_duplicates).to eq(1)
      end
    end
  end
end
