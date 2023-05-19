class Admin::SlackPresenceChecksController < Admin::BaseController
  def index
    @checks = SlackPresenceCheck.all.includes(:student)
  end
end