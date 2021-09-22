require 'rails_helper'

describe 'Zoom API Flow' do 
    # zoom api service
    # zoom api facade -- organize/combine data
    #     - meeting details (start_time)
    #     - meeting participant report details (name, join time, ~duration)

    
    # Iterating through participant hash that comes back from participant report details 
    # and compare each participants join time to the metting details start time and 

    # { "meeting_start_time": DateTime,
    # "participants":
    #     [{"Meg Stang (she/her)" => ParticipantReport.new({email: email, join_time: ... , status: 'present', duration: ...}), 
    #     "Brian Zanti" => ParticipantReport.new({email: email, join_time: ... , status: 'present', duration: ...}, 
    #     "Konham" => ParticipantReport.new(... status: absent)]
    # }
    


end 