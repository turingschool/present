require 'rails_helper'

describe 'Zoom API Flow' do 
    describe 'service' do 
        it 'retrieves meeting info' do 
            meeting_id = '94370567202'
            response = ZoomService.meeting_details(meeting_id)

            expect(response[:start_time]).to eq("2021-09-21T15:30:00Z")
            expect(response[:duration]).to eq(150)
        end 

        it 'retrieves participant info' do 
            meeting_id = '94370567202'
            response = ZoomService.past_participants_meeting_report(meeting_id)

            expect(response[:total_records]).to eq(236)
            expect(response[:participants]).to be_a(Array)
            expect(response[:participants].count).to eq(236)
            expect(response[:participants][0]).to have_key(:name)
            expect(response[:participants][0]).to have_key(:user_email)
            expect(response[:participants][0]).to have_key(:join_time)
            expect(response[:participants][0]).to have_key(:leave_time)
            expect(response[:participants][0]).to have_key(:duration)
        end 
    end 
    describe 'facade' do 
        xit 'produces a hash of meeting start time and participant data' do 
            meeting_id = '94370567202'
            participants_meeting_time_hash = ZoomFacade.past_participants_in_meeting(meeting_id)

            expect(participants_meeting_time_hash).to have_key("meeting_start_time")
            expect(participants_meeting_time_hash).to have_key("participants")
            expect(participants_meeting_time_hash["participants"]).to_be an_instance_of(ParticipantReport)
        end 
    end 

    describe 'poro' do 
        xit 'can make a ParticipantReport' do 
            participant_report = ParticipantReport.new('meg@test.com', "2021-09-21T15:28:19Z", 'present', 1826})

            expect(participant_report.email).to eq('meg@test.com')
            expect(participant_report.join_time).to eq(DateTime.parse("2021-09-21T15:28:19Z"))
            expect(participant_report.status).to eq('present')
            expect(participant_report.duration).to eq(1826)
        end 
    end 
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