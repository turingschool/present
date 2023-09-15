class InningRolloverJob
  include Sidekiq::Job

  def perform(inning_id)
    Inning.current_to_false
    inning = Inning.find_by(inning_id)
    inning.update(current: true)
    inning.create_turing_modules
  end
end
