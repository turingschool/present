class ParticipantReport 
    attr_reader :name, :email, :join_time

    def initialize(name, email, join_time, meeting_start_time, meeting_duration, student_duration)
        @name = name
        @email = email
        @meeting_duration = meeting_duration # in minutes
        if join_time
            @join_time = Time.parse(join_time)
        else 
            @join_time = nil 
        end 
        @meeting_start_time = Time.parse(meeting_start_time)
        @duration_values = []
        update_duration(student_duration) 
    end 

    def update_duration(student_duration)
        @duration_values << student_duration
    end 

    def status 
        return 'absent' if @join_time == nil
        minutes_passed_start_time = (@meeting_start_time - @join_time)/60
        return 'absent' if minutes_passed_start_time >= 30
        return 'tardy' if 1 <= minutes_passed_start_time
        return 'present'
    end 

    def duration 
        (((@duration_values.sum/60) / @meeting_duration) * 100).round(1).to_s + '%'
    end 
end 