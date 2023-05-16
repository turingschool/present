class WebsocketJob
  include Sidekiq::Job

    def perform()
      EM.run do
        ws_url = SlackWebsocketService.connect[:url]
        ws = Faye::WebSocket::Client.new(ws_url)
        p "=======================================START======================================="

        ws.on :open do |event|
          p "=======================================OPEN======================================="
          p event
        end

        ws.on :message do |event|
          p "=======================================MESSAGE======================================="
          puts event.data
        end

        ws.on :close do |event|
          p "=======================================CLOSE======================================="
          p event
          EventMachine.stop
        end
        
        ws.on :error do |event|
          p "=======================================ERROR======================================="
          p event
          EventMachine.stop
        end
      end
      p "=======================================END======================================="
    end
end
