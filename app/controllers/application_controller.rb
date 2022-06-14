class ApplicationController < ActionController::Base
  helper_method :current_user, :current_inning

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_inning
    @current_inning ||= Inning.find_by(current: true)
  end
end
