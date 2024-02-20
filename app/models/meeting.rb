class Meeting < ApplicationRecord
  self.abstract_class = true

  has_one :attendance, as: :meeting
  has_one :turing_module, through: :attendance
  has_one :inning, through: :turing_module

  def closest_populi_meeting_to_start_time(course_id)
    # need to restructure to access new API object
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

  def record_student_attendance(student, matching_participants, duration)
    student_attendance = attendance.student_attendances.find_or_create_by(student: student)
    best = matching_participants.min_by(&:join_time)
    if best.nil?
      student_attendance.update(duration: duration, status: "absent", join_time: nil)
    else
      best.assign_status!(attendance.attendance_time)
      student_attendance.update(duration: duration, status: best.status, join_time: best.join_time)
    end
    return student_attendance
  end
end