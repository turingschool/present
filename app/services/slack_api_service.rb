class SlackApiService 
  def self.get_presence(user_id)
    response = conn.get("user.getPresence") do |req|
      req.params[:user] = user_id
    end
    parse_response(response)
  end

private
  def self.conn 
    conn = Faraday.new(
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