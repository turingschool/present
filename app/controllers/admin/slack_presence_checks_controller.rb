class Admin::SlackPresenceChecksController < Admin::BaseController
  def index
    @checks = SlackPresenceCheck.all.includes(:student).page params[:page]
  end
end