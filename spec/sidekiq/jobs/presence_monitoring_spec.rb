require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe PresenceMonitoringJob, type: :job do
  before :each do
    Sidekiq::Testing.fake!
    ENV["PRESENCE_MONTIORING"] = "true"
  end

  it 'will queue a job to check presence for each module' do
    inning = create(:inning_with_modules)
    PresenceMonitoringJob.perform_async
    expect(PresenceMonitoringJob.jobs.size).to eq(1)
    PresenceMonitoringJob.drain
    expect(CheckStudentPresenceJob.jobs.size).to eq(13) # Queues a job for each module in the inning
  end

  it 'only executes if the PRESENCE_MONITORING env var is set to true' do
    Sidekiq::Testing.inline!

    expect {
      PresenceMonitoringJob.perform_async
    }.to raise_error(NoMethodError) # raises this error because there are no innings

    ENV["PRESENCE_MONTIORING"] = "false"
    expect {
      PresenceMonitoringJob.perform_async
    }.to_not raise_error # doesn't raise an error because the job shouldn't execute without the env var set to true
  end

  it 'will check presence for each module' do
    Sidekiq::Testing.inline!

    @inning = create(:inning, :current_past)
    mod1, mod2, mod3 = create_list(:turing_module, 3, inning: @inning)
    @student_1 = create(:student, turing_module: mod1, slack_id: "1")
    @student_2 = create(:student, turing_module: mod1, slack_id: "2")
    @student_3 = create(:student, turing_module: mod2, slack_id: "3")
    @student_4 = create(:student, turing_module: mod2, slack_id: "4")
    @student_5 = create(:student, turing_module: mod3, slack_id: "5")

    stub_request(:get, "https://slack.com/api/users.getPresence?user=1").
      to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))
        
    stub_request(:get, "https://slack.com/api/users.getPresence?user=2").
      to_return(status: 200, body: File.read("spec/fixtures/slack/presence_away.json"))

    stub_request(:get, "https://slack.com/api/users.getPresence?user=3").
      to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))
    
    stub_request(:get, "https://slack.com/api/users.getPresence?user=4").
      to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json"))
      
    stub_request(:get, "https://slack.com/api/users.getPresence?user=5").
      to_return(status: 200, body: File.read("spec/fixtures/slack/presence_active.json")) 
      
    check_time = Time.now
    allow(Time).to receive(:now).and_return(check_time)  

    PresenceMonitoringJob.perform_async

    expect(SlackPresenceCheck.count).to eq(5)
    expect(@student_1.slack_presence_checks.first.presence).to eq("active")
    expect(@student_1.slack_presence_checks.count).to eq(1)
    expect(@student_2.slack_presence_checks.first.presence).to eq("away")
    expect(@student_3.slack_presence_checks.first.presence).to eq("active")
    expect(@student_4.slack_presence_checks.first.presence).to eq("active")
    expect(@student_5.slack_presence_checks.first.presence).to eq("active")

    # call .to_fs(:short) to remove any precision past hour/minute/second
    expect(@student_1.slack_presence_checks.first.check_time.to_fs(:short)).to eq(check_time.to_fs(:short))
    expect(@student_2.slack_presence_checks.first.check_time.to_fs(:short)).to eq(check_time.to_fs(:short))
  end
end