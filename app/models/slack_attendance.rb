class SlackAttendance < ApplicationRecord 
    belongs_to :attendance

    # def pretty_time 
    #     attendance_start_time.in_time_zone('Mountain Time (US & Canada)').strftime('%l:%M %p').strip
    # end 

    # def pretty_time_date
    #     "Slack - " + attendance_start_time.in_time_zone('Mountain Time (US & Canada)').strftime('%b %d, %l:%M %p').strip
    # end 
end 