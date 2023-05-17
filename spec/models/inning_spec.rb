require 'rails_helper'

RSpec.describe Inning, type: :model do
  describe 'relationships' do 
    it {should have_many :turing_modules}
    it {should have_many(:students).through(:turing_modules)}
  end 

  describe 'validations' do
    it {should validate_presence_of :name}
    it 'has current set to false by default upon creation' do 
      inning = Inning.create(name: '2108')
      expect(inning.current).to eq(false)
    end 
  end 

  describe 'instance methods' do 
    it '#make_current_inning' do 
      past_innings = create_list(:inning,3)
      current_inning = create(:inning, current: true)
      
      past_innings.first.make_current_inning

      Inning.all.reload

      expect(past_innings.first.current).to eq(true)

      expect(Inning.where.not(id: past_innings.first.id).all?{ |inning| !inning.current }).to eq(true)
    end 

    describe "#check_presence_for_students" do
      before :each do
        @inning = create(:inning)
        mod1, mod2, mod3 = create_list(:turing_module, 3, inning: @inning)
        @student_1 = create(:student, turing_module: mod1, slack_id: "1")
        @student_2 = create(:student, turing_module: mod1, slack_id: "2")
        @student_3 = create(:student, turing_module: mod2, slack_id: "3")
        @student_4 = create(:student, turing_module: mod2, slack_id: "4")
        @student_5 = create(:student, turing_module: mod3, slack_id: "5")

        stub_request(:get, "https://slack.com/api/user.getPresence?user=1").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))
        
        stub_request(:get, "https://slack.com/api/user.getPresence?user=2").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_away.json"))

        stub_request(:get, "https://slack.com/api/user.getPresence?user=3").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))
        
        stub_request(:get, "https://slack.com/api/user.getPresence?user=4").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))
          
        stub_request(:get, "https://slack.com/api/user.getPresence?user=5").
          to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))  
      end

      it 'records the presence' do
        @inning.check_presence_for_students

        expect(SlackPresenceCheck.count).to eq(5)
        expect(@student_1.slack_presence_checks.first.presence).to eq("active")
        expect(@student_1.slack_presence_checks.count).to eq(1)
        expect(@student_2.slack_presence_checks.first.presence).to eq("away")
      end

      it 'records the check time' do
        check_time = Time.now
        allow(Time).to receive(:now).and_return(check_time)
        
        @inning.check_presence_for_students
        
        expect(@student_1.slack_presence_checks.first.check_time).to eq(check_time)
        expect(@student_2.slack_presence_checks.first.check_time).to eq(check_time)
      end
    end
  end 

  describe 'class methods' do 
    it '.order_by_name' do 
      inning_1 = Inning.create(name: '2201')
      inning_2 = Inning.create(name: '2108')
      inning_3 = Inning.create(name: '2210')

      expect(Inning.order_by_name).to eq([inning_3, inning_1, inning_2])
    end 
  end 

end
