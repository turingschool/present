class CheckStudentPresenceJob
  include Sidekiq::Job

  def perform(module_id)
    start = Time.now
    mod = TuringModule.find(module_id)
    mod.check_presence_for_students!
    end_time = Time.now
    time = (end_time - start).round
    Rails.logger.info "Checked Presence for Students in #{mod.name} id=#{mod.id} in #{time} seconds"
  end
end
