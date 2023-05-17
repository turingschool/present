class WebsocketJob
  include Sidekiq::Job

    def perform
      # https://api.slack.com/events/presence_change
      # If you're writing a library that supports presence_change events, you should be prepared to handle both kinds of presence events.
      ids = Inning.find_by(current: true).students.pluck(:slack_id)
      presence_sub = {
          "type": "presence_sub",
          "ids": ids
      }
      p "=======================================START======================================="
      EM.run do
        ws_url = SlackWebsocketService.connect[:url]
        ws = Faye::WebSocket::Client.new(ws_url)

        ws.on :open do |event|
          ws.send(presence_sub.to_json)
        end

        ws.on :message do |event|
          message_time = Time.now
          message = JSON.parse(event.data, symbolize_names: true)
          if message[:type] == "presence_change"
            p "=======================================PRESENCE CHANGED======================================="
            p message
            student = Student.find_by(slack_id: message[:user])
            if message[:presence] == "away"
              student.inactive_periods.create(start_time: message_time)
            elsif message[:presence] == "active"
              last_inactivity = student.inactive_periods.last
              if last_inactivity
                minutes_inactive = (message_time - last_inactivity.start_time) / 1.minute
                if minutes_inactive < 15
                  last_inactivity.destroy
                else
                  last_inactivity.update(end_time: message_time)
                end
              end
            end
          end
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
      # Remember to display the total time of inactivity on slack attendance show
      p "=======================================END======================================="
    end
end
