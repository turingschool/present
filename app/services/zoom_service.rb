require 'uri'
require 'net/http'

class ZoomService 
    def self.meeting_details(meeting_id)
        zoom_api("/v2/meetings/#{meeting_id}")
    end 

    def self.past_participants_meeting_report(meeting_id)
        zoom_api("/v2/report/meetings/#{meeting_id}/participants?page_size=300")
    end     

    def self.zoom_api(endpoint)
        url_string = "https://api.zoom.us" + endpoint
        url = URI(url_string)

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        request = Net::HTTP::Get.new(url)
        request["authorization"] = "Bearer #{ENV['ZOOM_JWT']}"
        request["content-type"] = 'application/json'
        
        response = http.request(request)
        parsed_body = JSON.parse(response.body, symbolize_names: true)
    end 

end 
