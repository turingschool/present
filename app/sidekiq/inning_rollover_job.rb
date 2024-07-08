class InningRolloverJob
  include Sidekiq::Job

  def perform(inning_id)
    ZoomAlias.all.destroy_all
    inning = Inning.find(inning_id)
    inning.make_current_inning
    inning.create_turing_modules
    User.reset_modules
  end
end
