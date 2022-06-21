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
    conn = Faraday.new(
      url: 'https://api.zoom.us',
      headers: {
        'Content-Type' => 'application/json',
        'authorization' => "Bearer #{generate_jwt}"
      }
    )
  end

  def self.generate_jwt
    payload = {
      "iss": ENV['ZOOM_API_KEY'],
      "exp": Time.now.to_i + 5
    }
    JWT.encode payload, ENV['ZOOM_API_SECRET'], 'HS256'
  end

  def self.parse_response(response)
    JSON.parse(response.body, symbolize_names: true)
  end
end
