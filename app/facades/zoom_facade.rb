class ZoomFacade
    def self.past_participants_in_meeting(meeting_id, full_roster_names)
        meeting_details = ZoomService.meeting_details(meeting_id)
        participants = ZoomService.past_participants_meeting_report(meeting_id)[:participants]

        meeting_start_time = meeting_details[:start_time]
        meeting_duration = meeting_details[:duration]
        create_participants_report_hash(meeting_start_time, meeting_duration, participants, full_roster_names)
    end

    def self.create_participants_report_hash(meeting_start_time, meeting_duration, participants, full_roster_names)
        participants_report_hash = {"meeting_start_time": DateTime.parse(meeting_start_time), "participants": {}}
        participants.each do |participant|
            name = participant[:name]
            if participants_report_hash[:participants][name]
                participant_report = participants_report_hash[:participants][name]
                participant_report.update_duration(participant[:duration])
            else
                email = participant[:user_email]
                join_time = participant[:join_time]
                duration = participant[:duration]

                participants_report_hash[:participants][participant[:name]] = ParticipantReport.new(name, email, join_time, meeting_start_time, meeting_duration,duration)
            end
        end

        find_absent_students(participants_report_hash[:participants].keys, full_roster_names).each do |absent_student|
            participants_report_hash[:participants][absent_student] = ParticipantReport.new(absent_student, nil, nil, meeting_start_time, meeting_duration, 0)
        end

        participants_report_hash
    end

    def self.find_absent_students(participants, full_roster_names)
        full_roster_names - participants
    end
end
