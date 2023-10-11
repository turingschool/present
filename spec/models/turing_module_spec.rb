require 'rails_helper'

RSpec.describe TuringModule, type: :model do
  describe 'relationships' do
    it { should belong_to :inning }
    it { should have_many :attendances }
    it { should have_many :students }
  end

  it { should validate_presence_of :program }
  it { should validate_numericality_of(:module_number).is_greater_than_or_equal_to(1) }
  it { should validate_numericality_of(:module_number).is_less_than_or_equal_to(6) }
  it { should validate_numericality_of(:module_number).only_integer }
  it { should define_enum_for(:program).with_values(([:FE, :BE, :Combined, :Launch])) }


  describe 'instance methods' do
    describe "#unclaimed_aliases" do
      before :each do
        @attendance = create(:attendance)
        @module = @attendance.turing_module
        @other_attendance = create(:attendance, turing_module: @module)
        
        @unclaimed = create_list(:zoom_alias, 2, zoom_meeting: @attendance.meeting, turing_module: @module)
        @other_unclaimed = create_list(:zoom_alias, 2, zoom_meeting: @other_attendance.meeting, turing_module: @module)
        @claimed = create_list(:alias_for_student, 2, zoom_meeting: @attendance.meeting, turing_module: @module)
        @other_claimed = create_list(:alias_for_student, 2, zoom_meeting: @other_attendance.meeting, turing_module: @module)
      end

      it 'returns all aliases from all zoom meetings that have no student assigned' do
        expect(@module.unclaimed_aliases.sort).to eq(@unclaimed + @other_unclaimed)
      end

      it 'Does not include aliases from other modules' do
        expect {
          create(:zoom_alias) 
        }.to_not change {
          @module.unclaimed_aliases.length
        }
      end
    end


    describe '#name' do
      it 'returns a combo of the module number and program' do
        test_module = create(:setup_module)
        expect(test_module.name).to eq('BE Mod 3')
      end
    end

    describe '#account_match_complete' do 
      it 'returns true if some students in a mod have slack ids, and some have zoom ids' do 
        test_module = create(:setup_module)

        expect(test_module.account_match_complete).to eq true 
      end 
      it 'returns false if some students in a mod have slack ids but none have zoom ids' do 
        test_module = create(:turing_module)
        
        expect(test_module.account_match_complete).to eq false 
      end 

      it 'returns false if no students have slack or zoom ids' do 
        test_module = create(:turing_module)

        expect(test_module.account_match_complete).to eq false 
      end 
    end 
  end
end
