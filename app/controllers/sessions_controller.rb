class SessionsController < ApplicationController
  def create
    user_attributes = {
      google_id: auth_hash['uid'],
      email: auth_hash['info']['email'],
      google_oauth_token: auth_hash['credentials']['token']
    }
    user = User.find_or_create_by(google_id: auth_hash['uid'])
    user.update({
      email: auth_hash['info']['email'],
      google_oauth_token: auth_hash['credentials']['token'],
      google_refresh_token: auth_hash['credentials']['refresh_token'],
      organization_domain: auth_hash["extra"]["raw_info"]["hd"]
    })
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path
  end

  private
  def auth_hash
    request.env['omniauth.auth']
  end
end
