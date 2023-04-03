class AttendanceShowFacade
  include StringMatcher

  def initialize(attendance)
    @attendance = attendance
  end
  
  def alias_options_for(student)
    @attendance.meeting.unclaimed_aliases.sort_by do |zoom_alias|
      -1 * string_distance(student.name, zoom_alias.name)
    end.map do |zoom_alias|
      [zoom_alias.name, zoom_alias.id]
    end
  end

  def student_attendances
    @attendance.student_attendances.by_attendance_status
  end
end