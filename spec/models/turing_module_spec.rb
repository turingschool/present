require 'rails_helper'

RSpec.describe TuringModule, type: :model do
  describe 'relationships' do
    it { should belong_to :inning }
    it { should have_many :attendances }
    it { should have_many :students }
  end

  it { should validate_presence_of :program }
  it { should validate_numericality_of(:module_number).is_greater_than_or_equal_to(1) }
  it { should validate_numericality_of(:module_number).is_less_than_or_equal_to(4) }
  it { should validate_numericality_of(:module_number).only_integer }
  it { should define_enum_for(:program).with_values(([:FE, :BE, :Combined])) }


  describe 'instance methods' do
    describe '#name' do
      it 'returns a combo of the module number and program' do
        test_module = create(:turing_module, program: :FE, module_number: 3)
        expect(test_module.name).to eq('FE Mod 3')
      end
    end

    describe '#account_match_complete' do 
      it 'returns true if some students in a mod have slack ids, and some have zoom ids' do 
        test_module = create(:fe1)
        students = create_list(:student, 5, turing_module: test_module)

        expect(test_module.account_match_complete).to eq true 
      end 
      it 'returns false if some students in a mod have slack ids but none have zoom ids' do 
        test_module = create(:fe1)
        create_list(:student, 3, zoom_id: nil, turing_module: test_module)
        create_list(:student, 2, slack_id: nil, zoom_id: nil, turing_module: test_module)
        
        expect(test_module.account_match_complete).to eq false 
      end 

      it 'returns false if no students have slack or zoom ids' do 
        test_module = create(:fe1)
        students = create_list(:student, 5, slack_id: nil, zoom_id: nil, turing_module: test_module)

        expect(test_module.account_match_complete).to eq false 
      end 
    end 
  end
end
