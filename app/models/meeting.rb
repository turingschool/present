class Meeting < ApplicationRecord
  self.abstract_class = true

  def closest_populi_meeting_to_start_time(course_id)
    meeting_data = PopuliService.new.course_meetings(course_id)[:response][:meeting].min_by do |data|
      (start_time.to_i - data[:start].to_datetime.to_i).abs
    end
    PopuliMeeting.new(meeting_data)
  end

  def populi_meetings_on_same_day(course_id)
    meeting_day = start_time.to_date
    meetings = PopuliService.new.course_meetings(course_id)[:response][:meeting].find_all do |data|
      meeting_day == Date.parse(data[:start])
    end
    meetings.map{|data| PopuliMeeting.new(data)}
  end
end