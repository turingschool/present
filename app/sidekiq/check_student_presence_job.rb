class CheckStudentPresenceJob
  include Sidekiq::Job

  def perform(module_id)
    TuringModule.find(module_id).check_presence_for_students!
  end
end
