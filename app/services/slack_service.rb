class SlackService 
    def self.get_channel_members(channel_id)
        response = conn.get("/api/v0/channel_members?channel_id=#{channel_id}")
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