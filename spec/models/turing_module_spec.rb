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
    describe "#check_presence_for_students!" do
      before :each do
        @mod1 = create(:turing_module)
        @student_1 = create(:student, turing_module: @mod1, slack_id: "1")
        @student_2 = create(:student, turing_module: @mod1, slack_id: "2")
        @student_3 = create(:student, turing_module: @mod1, slack_id: "3")
        @student_4 = create(:student, turing_module: @mod1, slack_id: "4")
        @student_5 = create(:student, turing_module: @mod1, slack_id: "5")

        stub_request(:get, "https://slack.com/api/users.getPresence?user=1").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))
        
        @user2_stub = stub_request(:get, "https://slack.com/api/users.getPresence?user=2").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_away.json"))

        @user3_stub = stub_request(:get, "https://slack.com/api/users.getPresence?user=3").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))
        
        stub_request(:get, "https://slack.com/api/users.getPresence?user=4").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))
          
        @user5_stub = stub_request(:get, "https://slack.com/api/users.getPresence?user=5").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))  
      end

      it 'records the presence' do
        @mod1.check_presence_for_students!

        expect(SlackPresenceCheck.count).to eq(5)
        expect(@student_1.slack_presence_checks.first.presence).to eq("active")
        expect(@student_1.slack_presence_checks.count).to eq(1)
        expect(@student_2.slack_presence_checks.first.presence).to eq("away")
      end

      it 'records the check time' do
        check_time = Time.now
        allow(Time).to receive(:now).and_return(check_time)
        
        @mod1.check_presence_for_students!

        # call .to_fs(:short) to remove any precision past hour/minute/second
        expect(@student_1.slack_presence_checks.first.check_time.to_fs(:short)).to eq(check_time.to_fs(:short))
        expect(@student_2.slack_presence_checks.first.check_time.to_fs(:short)).to eq(check_time.to_fs(:short))
      end

      it "retries up to 5 times upon receiving a failure" do
        stub_request(:get, "https://slack.com/api/users.getPresence?user=2").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_error.json"))

        stub_request(:get, "https://slack.com/api/users.getPresence?user=3").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_error.json"))
        
        stub_request(:get, "https://slack.com/api/users.getPresence?user=5").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_error.json"))

        @mod1.check_presence_for_students!
        
        # expect 6 times for 1 initial call plus 5 retries
        expect(@user2_stub).to have_been_requested.times(6)
        expect(@user3_stub).to have_been_requested.times(6)
        expect(@user5_stub).to have_been_requested.times(6)
        expect(@student_2.slack_presence_checks.count).to eq(0)
        expect(@student_3.slack_presence_checks.count).to eq(0)
        expect(@student_5.slack_presence_checks.count).to eq(0)
        # 2 students should have successful presence checks
        expect(SlackPresenceCheck.pluck(:student_id).sort).to eq([@student_1.id, @student_4.id].sort)
      end
    end

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
      it 'returns true if all the students in the module have slack ids' do 
        test_module = create(:setup_module)

        expect(test_module.account_match_complete).to eq true 
      end 

      it 'returns false if no students in a mod have slack ids' do 
        test_module = create(:turing_module)
        
        expect(test_module.account_match_complete).to eq false 
      end 
    
      it 'returns true if some students in a mod have slack ids' do 
        test_module = create(:turing_module)

        students = create_list(:student, 2, turing_module: test_module)
        students.first.update(slack_id: "some id")
        
        expect(test_module.account_match_complete).to eq true 
      end 
    end 
  end
end
