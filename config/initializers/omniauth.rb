Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    provider :google_oauth2, ENV['GOOGLE_OAUTH_CLIENT_ID'], ENV['GOOGLE_OAUTH_CLIENT_SECRET']
  else
    provider :google_oauth2, ENV['GOOGLE_OAUTH_CLIENT_ID'], ENV['GOOGLE_OAUTH_CLIENT_SECRET'],
    {
      redirect_uri: 'http://localhost:3000/auth/google_oauth2/callback',
      scope: 'spreadsheets,email'
    }
  end
end
OmniAuth.config.allowed_request_methods = %i[get post]
