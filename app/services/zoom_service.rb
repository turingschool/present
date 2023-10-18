class ZoomService
  def self.meeting_details(meeting_id)
    response = conn.get "/v2/meetings/#{meeting_id}"
    parse_response(response)
  end

  def self.participant_report(meeting_id)
    response = conn.get "/v2/report/meetings/#{meeting_id}/participants?page_size=300"
    parse_response(response)
  end

private
  def self.conn
    Faraday.new(
      url: 'https://api.zoom.us',
      headers: {
        'Content-Type' => 'application/json',
        'authorization' => "Bearer #{access_token}"
      }
    )
  end

  def self.access_token
    Rails.cache.fetch("zoom_oauth_token", expires_in: 55.minutes) do
      response = auth_conn.post
      JSON.parse(response.body)["access_token"]
    end
  end  

  def self.auth_conn
    Faraday.new(url: "https://zoom.us/oauth/token") do |conn|
      conn.request :basic_auth, ENV["ZOOM_CLIENT_ID"], ENV["ZOOM_CLIENT_SECRET"]
      conn.params["grant_type"] = "account_credentials"
      conn.params["account_id"] = ENV["ZOOM_ACCOUNT_ID"]
    end
  end

  def self.parse_response(response)
    JSON.parse(response.body, symbolize_names: true)
  end
end
