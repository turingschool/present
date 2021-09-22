class User::BaseController < ApplicationController
  before_action :verify_google_user

  def verify_google_user
    redirect_to '/welcome' unless valid_google_user? && valid_google_oauth_token?
    # redirect_to '/welcome' unless valid_google_oauth_token?

  end

  def valid_google_user?
    current_user
  end

  def valid_google_oauth_token?
    begin
      sheet_data = GoogleSheetsService.get_sheet_matrix(TuringModule.first, current_user)
      sheet_matrix = sheet_data[:values]
      return true
    rescue NoMethodError
      session.delete(:user_id)
      return false
      # if current_user.google_refresh_token
      #   token = GoogleService.exchange_refresh_token(user)
      #   user.update(google_oauth_token: token)
      #   return true
      # else
      #   return false
      # end
    end
  end
end
