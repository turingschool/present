class PresenceMonitoringJob
  include Sidekiq::Job

  def perform
    Inning.find_by(current: true).check_presence_for_students
  end
end
