class Admin::BaseController < ApplicationController
  before_action :verify_admin

  def verify_admin
    if current_user.nil?
      render 'welcome/index'
    elsif !current_user.valid_google_user? || !current_user.admin?
      render 'error/unauthorized'
    end
  end
end