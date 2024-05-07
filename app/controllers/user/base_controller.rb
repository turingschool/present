class User::BaseController < ApplicationController
  before_action :verify_google_user

  def verify_google_user
    if current_user.nil?
      render 'welcome/index'
    elsif !current_user.valid_google_user?
      render 'error/unauthorized'
    end
  end
end
