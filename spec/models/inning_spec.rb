require 'rails_helper'

RSpec.describe Inning, type: :model do
  describe 'relationships' do 
    it {should have_many :turing_modules}
    it {should have_many(:students).through(:turing_modules)}
  end 

  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :start_date}
    
    it 'has current set to false by default upon creation' do 
      inning = Inning.create(name: '2108')
      expect(inning.current).to eq(false)
    end 

    describe '#date_within_allowed_range validation' do
      it 'start_date must be at least 12 weeks after the current innings start_date' do
        inning1 = create(:inning, :is_current)
        inning = Inning.new(name: '2108', start_date: Date.today)

        expect(inning).to_not be_valid
        expect(inning.errors.full_messages).to eq(["Start date must be at least 7 weeks after the start of the current inning"])
      end

      it 'if there are zero innings in the database, date_within_allowed_range validation does not apply' do
        expect(Inning.count).to eq(0)
        inning = Inning.new(name: '2108', start_date: Date.today, :current => true)
        expect(inning).to be_valid
        inning.save
        expect(Inning.count).to eq(1)
      end
    end
  end 

  describe 'instance methods' do 
    it '#make_current_inning' do 
      inning1 = create(:inning, :current_past, name: '2104')
      inning2 = create(:inning, :not_current_future, name: '2107')
      inning3 = create(:inning, :not_current_future, name: '2201')

      expect(inning1.current).to eq(true)

      inning2.make_current_inning

      Inning.all.reload

      expect(inning2.current).to eq(true)

      expect(Inning.where.not(id: inning2.id).all?{ |inning| !inning.current }).to eq(true)
    end

    it '#create_turing_modules' do
      inning1 = create(:inning, :current_past, name: '2203')
      inning2 = create(:inning, :not_current_future, name: "2301")

      expect(inning1.turing_modules.count).to eq(0)
      
      inning1.create_turing_modules
      
      expect(inning1.turing_modules.count).to eq(13)
      expect(inning2.turing_modules.count).to eq(0)

      expect(inning1.turing_modules.where(program: 'FE').count).to eq(3)
      expect(inning1.turing_modules.where(program: 'BE').count).to eq(3)
      expect(inning1.turing_modules.where(program: 'Combined').count).to eq(1)
      expect(inning1.turing_modules.where(program: 'Launch').count).to eq(6)

      expect(inning1.turing_modules.where(module_number: 1).count).to eq(3)
      expect(inning1.turing_modules.where(module_number: 2).count).to eq(3)
      expect(inning1.turing_modules.where(module_number: 3).count).to eq(3)
      expect(inning1.turing_modules.where(module_number: 4).count).to eq(2)
      expect(inning1.turing_modules.where(module_number: 5).count).to eq(1)
      expect(inning1.turing_modules.where(module_number: 6).count).to eq(1)
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

        @inning.check_presence_for_students
        
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

    describe "#process_presence_data_for_slack_attendances!" do
      before :each do
        @current_inning = create(:inning, :current_past)
        @module, @other_module = create_list(:turing_module, 2, inning: @current_inning)
        @attendance_check_complete = create(:slack_attendance, :presence_check_complete, turing_module: @module)
        @attendance_check_incomplete = create(:slack_attendance, :presence_check_incomplete, turing_module: @module)
        @other_attendance_check_complete = create(:slack_attendance, :presence_check_complete, turing_module: @other_module)
        @other_attendance_check_incomplete = create(:slack_attendance, :presence_check_incomplete, turing_module: @other_module)
        @zoom_attendance = create(:zoom_attendance, turing_module: @other_module)
        # 1 current inning
        # 2 modules for the inning (2 total)
        # 4 students in each module (8 total)
        # 2 attendances for each module (4 total)
            # one with presence check complete 
            # each one is an hour in length
        # For the attendances with presence check not complete
          # one student has no presence checks
          # one student active presence checks for some of the 15 minute blocks
          # one student has active presence checks for all of the 15 minute blocks
          # one student has away presence checks for all of the 15 minute blocks
      end

      
      it "will change slack attendances that haven't been marked complete" do
        expect { @current_inning.process_presence_data_for_slack_attendances! }.
          to change { @attendance_check_incomplete.student_attendance_hours.count} 
      end

      it 'does not change zoom attendances' do
        expect { @current_inning.process_presence_data_for_slack_attendances! }.
          to_not change { @zoom_attendance.student_attendance_hours.count} 
      end

      it 'does not change a slack attendance that has already been marked completed' do
        expect { @current_inning.process_presence_data_for_slack_attendances! }.
          to_not change { @attendance_check_complete.student_attendance_hours.count} 
      end

      it "works for multiple modules" do
        expect { @current_inning.process_presence_data_for_slack_attendances! }.
          to change { @other_attendance_check_incomplete.student_attendance_hours.count} 
      end

      it "does not touch any attendances from other innings" do
        @invalid_module = create(:turing_module)
        create(:student, turing_module: @invalid_module)
        @attendance_from_other_inning = create(:slack_attendance, :presence_check_incomplete, turing_module: @invalid_module)
        expect {@current_inning.process_presence_data_for_slack_attendances! }.
          to_not change { @attendance_from_other_inning.student_attendance_hours.count }
      end
    end
  end 

  describe 'class methods' do 
    it '.order_by_name' do 
      inning_1 = Inning.create(name: '2201', start_date: Date.today, current: true)
      inning_2 = Inning.create(name: '2108', start_date: Date.today+7.weeks)
      inning_3 = Inning.create(name: '2210', start_date: Date.today+14.weeks)

      expect(Inning.order_by_name).to eq([inning_3, inning_1, inning_2])
    end 

    it '.current_and_future' do
      inning1 = create(:inning, :current_past, name: '2104')
      inning2 = create(:inning, current: false, name: '2111', start_date: Date.today+19.weeks)
      inning3 = create(:inning, current: false, name: '2201', start_date: Date.today+26.weeks)
      inning4 = create(:inning, :not_current_future, name: '2107')
      
      inning4.make_current_inning

      expect(Inning.current_and_future).to eq([inning4, inning2, inning3])
    end
  end 
end
