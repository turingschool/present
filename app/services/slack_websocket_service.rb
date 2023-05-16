require 'faraday'

class SlackWebsocketService
    def self.conn 
        conn = Faraday.new(
            url: 'https://slack.com/api',
            headers: {
              'Content-Type' => 'application/x-www-form-urlencoded',
              'Authorization' => "Bearer #{ENV['slack_api_key']}"
            }
          )
    end 

    def self.connect
      endpoint = "rtm.connect"
      response = conn.get(endpoint)
      JSON.parse(response.body,symbolize_names: true)
    end 
    

end 



	