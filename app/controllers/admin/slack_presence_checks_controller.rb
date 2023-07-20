class Admin::SlackPresenceChecksController < Admin::BaseController
  def index
    @checks = SlackPresenceCheck.collect_for_pagination.page params[:page]
  end
end