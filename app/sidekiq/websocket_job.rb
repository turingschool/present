class WebsocketJob
  include Sidekiq::Job

    def perform()
      # https://api.slack.com/events/presence_change
      # If you're writing a library that supports presence_change events, you should be prepared to handle both kinds of presence events.
      presence_sub = {
          "type": "presence_sub",
          "ids": [
            "U047MM62LJE",                                                                                                            
            "U044E9188LC",                                                                                                            
            "U03T2HZ7F1S",                                                                                                            
            "U03STG12Y6A",                                                                                                            
            "U03SKRYN13R",                                                                                                            
            "U047MLWHZU2",                                                                                                            
            "U043X8QTNSK",                                                                                                            
            "U03SQE9FK1V",                                                                                                            
            "U03STR60L78",                                                                                                            
            "U047JN8A6S1",                                                                                                            
            "U044BR95JR0",                                                                                                            
            "U03TQ51EUFJ",                                                                                                            
            "U03T059E3C2",
            "U03LZK1PNDP",
            "U047JN8DH8V",
            "U03SKH188K1",
            "U0451GG9RDW",
            "U047F371CNS",
            "U047JN6TWLD",
            "U044BNHR1R9",
            "U047MM749DY",
            "U03SQE8BA4X",
            "U03SQE9B19V",
            "U03TQ4SRCLQ",
            "U044E912NDA",
            "U03EMK6GFGA",
            "U03KYFCP1FG",
            "U044BR8C7K4",
            "U047MJF8N1Z",
            "U03LLV9AMNE",
            "U03SXAAC5V5",
            "U0480A5DM5F",
            "U03TCPA652M",
            "U03SXEYUWHK",
            "U03TQ51HRFA",
            "U047Q4X2CLU",
            "U047Q55LAS0",
            "U03TCPA9KMX",
            "U03TEC7P0R2",
            "U03STG0UB9C",
            "U044E90SXAQ",
            "U047MJQSSGK",
            "U03T059HPRQ",
            "U047F2WGGTG",
            "U03EETG1M70",
            "U03SKH14KN3",
            "U03TBT6BDC2",
            "U03FBB5135E",
            "U04774QGMK9"
          ]
      }
      p "=======================================START======================================="
      require 'pry';binding.pry
      EM.run do
        ws_url = SlackWebsocketService.connect[:url]
        ws = Faye::WebSocket::Client.new(ws_url)

        ws.on :open do |event|
          ws.send(presence_sub.to_json)
        end

        ws.on :message do |event|
          message = JSON.parse(event.data, symbolize_names: true)
          p message
          if message[:type] == "presence_change"
            p "=======================================PRESENCE CHANGED======================================="
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
      p "=======================================END======================================="
    end
end
