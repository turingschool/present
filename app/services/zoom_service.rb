class ZoomService
  def self.meeting_details(meeting_id)
    try_request do 
      conn.get "/v2/meetings/#{meeting_id}"
    end
  end

  def self.participant_report(meeting_id)
    try_request do
      conn.get "/v2/report/meetings/#{meeting_id}/participants?page_size=300"
    end
  end

private
  def self.try_request(&request)
    body = parse_response(request.call)
    if body[:code].to_i == 124
      Rails.cache.delete("zoom_oauth_token")
      body = parse_response(request.call)
    end
    return body
  end

  def self.conn
    Faraday.new(
      url: 'https://api.zoom.us',
      headers: {
        'Content-Type' => 'application/json',
        'authorization' => "Bearer #{access_token}"
      }
    )
  end

  def self.auth_conn
    Faraday.new(url: "https://zoom.us/oauth/token") do |conn|
      conn.request :basic_auth, ENV["ZOOM_CLIENT_ID"], ENV["ZOOM_CLIENT_SECRET"]
    end
  end

  def self.access_token
    Rails.cache.fetch("zoom_oauth_token", expires_in: 55.minutes) do
      Rails.logger.info "Requesting new Zoom Oauth Token"
      response = auth_conn.post do |req|
        req.body = {
          account_id: ENV["ZOOM_ACCOUNT_ID"],
          grant_type: "account_credentials"
        }.to_query
      end
      JSON.parse(response.body)["access_token"]
    end
  end  

  def self.parse_response(response)
    JSON.parse(response.body, symbolize_names: true)
  end
end
