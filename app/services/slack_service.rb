class SlackService 
    def self.get_channel_members(channel_id)
        response = conn.get("/api/v0/channel_members?channel_id=#{channel_id}")
        parse_response(response)
    end

    def self.replies_from_message(channel_id,timestamp)
        response = conn.get("/api/v0/attendance?channel_id=#{channel_id}&timestamp=#{timestamp}")
        parse_response(response)
    end 
    
    private
      def self.conn
        conn = Faraday.new('https://slack-attendance-service.herokuapp.com')
      end 

      def self.parse_response(response)
        JSON.parse(response.body, symbolize_names: true)
      end
end 