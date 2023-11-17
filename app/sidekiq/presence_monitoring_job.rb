class PresenceMonitoringJob
  include Sidekiq::Job

  def perform
    if ENV["PRESENCE_MONTIORING"] == "true"
      Inning.find_by(current: true).turing_modules.each do |mod|
        CheckStudentPresenceJob.perform_async(mod.id)
      end
    end
  end
end
