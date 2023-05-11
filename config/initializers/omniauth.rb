OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true

SETUP_PROC = lambda do |env|
  env['omniauth.strategy'].options[:client_id] = ENV['GOOGLE_OAUTH_CLIENT_ID']
  env['omniauth.strategy'].options[:client_secret] = ENV['GOOGLE_OAUTH_CLIENT_SECRET']
  env['omniauth.strategy'].options[:scope] = 'spreadsheets,email'
  unless Rails.env.development?
    env['access_type'].options[:access_type] = "offline"
  end

  # Oauth should redirect back to the originating domain to prevent CSRF errors
  req = Rack::Request.new(env)
  env['omniauth.strategy'].options[:redirect_uri] = "#{req.base_url}/auth/google_oauth2/callback"
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, setup: SETUP_PROC
end

