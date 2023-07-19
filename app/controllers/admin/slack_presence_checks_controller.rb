class Admin::SlackPresenceChecksController < Admin::BaseController
  def index
    @checks = SlackPresenceCheck.all.includes(:student).order(id: :desc).page params[:page]
  end
end