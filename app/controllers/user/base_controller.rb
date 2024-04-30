class User::BaseController < ApplicationController
  before_action :verify_google_user
  rescue_from NoMethodError, with: :no_api_response

  def verify_google_user
    if current_user.nil?
      render 'welcome/index'
    elsif !current_user.valid_google_user?
      render 'error/unauthorized'
    end
  end

  def no_api_response
    @current_module = TuringModule.find(params[:turing_module_id])
    flash[:error] = "The page you are trying to access is currently unavailable. This may be due to an API call failing. Please try again later."
    redirect_to turing_module_path(@current_module)
  end
end
