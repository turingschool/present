class Meeting < ApplicationRecord
  self.abstract_class = true

  def closest_populi_meeting_to_start_time(course_id)
    data = PopuliService.new.course_meetings(course_id)[:response][:meeting].min_by do |data|
      (start_time.to_i - data[:start].to_datetime.to_i).abs
    end
    PopuliMeeting.new(data)
  end
end