class InningRolloverJob
  include Sidekiq::Job

  def perform(inning_id)
    inning = Inning.find(inning_id)
    inning.make_current_inning
    inning.create_turing_modules
    User.reset_modules
  end
end
