class Admin::SlackPresenceChecksController < ApplicationController
  def index
    @checks = SlackPresenceCheck.all.includes(:student)
  end
end