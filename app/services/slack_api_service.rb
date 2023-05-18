class SlackApiService 
  extend Limiter::Mixin
  # Rate limit users.getPresence api call to 50 requests per minute
  limit_method :get_presence, rate: 50 

  def get_presence(user_id)
    response = conn.get("users.getPresence") do |req|
      req.params[:user] = user_id
    end
    parse_response(response)
  end

private
  def conn 
    Faraday.new(
      url: 'https://slack.com/api',
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Authorization' => "Bearer #{ENV['slack_api_key']}"
      }
    )
  end

  def self.parse_response(response)
    JSON.parse(response.body, symbolize_names: true)
  end
end 