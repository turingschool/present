class AttendanceShowFacade
  include StringMatcher

  def initialize(attendance)
    @attendance = attendance
  end
  
  def alias_options_for(student)
    @attendance.meeting.unclaimed_aliases.sort_by do |name, id|
      -1 * string_distance(student.name, name)
    end
  end

  def student_attendances
    @attendance.student_attendances.includes(:student).by_attendance_status
  end
end