class ProcessPresenceDataJob
  include Sidekiq::Job

  def perform
    Inning.find_by(current: true).process_presence_data_for_slack_attendances!
  end
end
