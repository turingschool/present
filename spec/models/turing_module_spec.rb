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
            :user_id=>"16778240",
            :name=>"Ryan Teske (He/Him)",
            :user_email=>"ryanteske@outlook.com",
          },
          {
            :user_id=>"16779264",
            :name=>"Isika P (she/her# BE)",
            :user_email=>"",
          },
          {
            :user_id=>"16780288",
            :name=>"Natalia ZV (she/her)# FE",
            :user_email=>"nzamboniv@gmail.com",
          },
          {
            :user_id=>"16781312",
            :name=>"Jamie P (she/her)# BE",
            :user_email=>"jamiejpace@gmail.com",
          },
          {
            :user_id=>"16782336",
            :name=>"Tanner D (he/him)# BE",
            :user_email=>"",
          }
        ]
      }

      it 'creates a student for each participant' do
        test_module = create(:fe1)
        test_module.create_students_from_participants(participants)
        expect(test_module.students.length).to eq(participants.length)
        all_participants_created = participants.all? do |participant|
          test_module.students.any? do |student|
            student.name == participant[:name] &&
            student.zoom_email == participant[:user_email] &&
            student.zoom_id == participant[:user_id]
          end
        end
        expect(all_participants_created).to eq(true)
      end
    end
  end
end
