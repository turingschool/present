require 'rails_helper'

describe 'Zoom API Flow' do 
    describe 'service' do 
        it 'retrieves meeting info' do 
            meeting_id = '95544205456'
            response = ZoomService.meeting_details(meeting_id)

            expect(response[:start_time]).to eq("2021-09-21T15:00:00Z")
            expect(response[:duration]).to eq(30)
        end 

        it 'retrieves participant info' do 
            meeting_id = '95544205456'
            response = ZoomService.past_participants_meeting_report(meeting_id)

            expect(response[:total_records]).to eq(96)
            expect(response[:participants]).to be_a(Array)
            expect(response[:participants].count).to eq(96)
            expect(response[:participants][0]).to have_key(:name)
            expect(response[:participants][0]).to have_key(:user_email)
            expect(response[:participants][0]).to have_key(:join_time)
            expect(response[:participants][0]).to have_key(:leave_time)
            expect(response[:participants][0]).to have_key(:duration)
        end 
    end 
    describe 'facade' do 
        it 'produces a hash of meeting start time and participant data' do 
            meeting_id = '95544205456'
            participants_meeting_time_hash = ZoomFacade.past_participants_in_meeting(meeting_id, full_roster_names)

            expect(participants_meeting_time_hash).to have_key(:meeting_start_time)
            expect(participants_meeting_time_hash).to have_key(:participants)
            expect(participants_meeting_time_hash[:participants][full_roster_names.first]).to be_an_instance_of(ParticipantReport)

            expect(participants_meeting_time_hash[:participants].count).to eq(40)
        end 
    end 

    describe 'poro' do 
        it 'can make a ParticipantReport' do 
            # ParticipantReport(name, email,join time, meeting start time, duration)
            participant_report = ParticipantReport.new('Meg Stang(she/her)', 'meg@test.com', "2021-09-21T14:57:49Z", "2021-09-21T15:00:00Z", 30, 1826)
            expect(participant_report.email).to eq('meg@test.com')
            expect(participant_report.join_time).to eq(Time.parse("2021-09-21T14:57:49Z"))
            expect(participant_report.status).to eq('tardy')
            expect(participant_report.duration).to eq('100%')
        end 
    end 
    # zoom api service
    # zoom api facade -- organize/combine data
    #     - meeting details (start_time)
    #     - meeting participant report details (name, join time, ~duration)

    
    # Iterating through participant hash that comes back from participant report details 
    # and compare each participants join time to the metting details start time and 

    # { "meeting_start_time": DateTimeObject,
    # "participants": {
    #     "Meg Stang (she/her)" => ParticipantReport.new(...), 
    #     "Brian Zanti (he/him)" => ParticipantReport.new(...)
    #     }
    # }

    # ParticipantReport has access to these methods: 
    #     - name (you don't really need this since it's in the key, but figured i'd throw it in to the object anyway)
    #     - email (you don't need this)
    #     - join_time (you don't need this)
    #     - duration (returned as a percent of full duration in class compared to meeting length)
    #     - status (returns 'absent', 'tardy', or 'present')
end 