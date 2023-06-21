class PresenceMonitoringJob
  include Sidekiq::Job

  def perform
    if ENV["PRESENCE_MONTIORING"] == "true"
      Inning.find_by(current: true).check_presence_for_students
    end
  end
end
