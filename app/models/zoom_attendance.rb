class ZoomAttendance < ApplicationRecord 
    belongs_to :attendance

    def am_or_pm
        meeting_time.in_time_zone('Mountain Time (US & Canada)').strftime('%p')
      end
    
      def pretty_time
        meeting_time.in_time_zone('Mountain Time (US & Canada)').strftime('%l:%M %p').strip
      end
end 