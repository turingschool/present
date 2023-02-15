class ApplicationController < ActionController::Base
  helper_method :current_user, :current_inning

  rescue_from ActiveRecord::RecordNotFound, with: :clear_current_user

  def clear_current_user(error)
    if error.message == "Couldn't find User with 'id'=#{session[:user_id]}"
      session.delete(:user_id)
      redirect_to root_path
    else
      raise error
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_inning
    @current_inning ||= Inning.find_by(current: true)
  end
end
