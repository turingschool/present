class AttendanceShowFacade
  include StringMatcher

  def initialize(attendance)
    @attendance = attendance
  end
  
  def alias_options_for(student)
    @attendance.unclaimed_aliases.sort_by do |zoom_alias|
      -1 * string_distance(student.name, zoom_alias.name)
    end.map do |zoom_alias|
      [zoom_alias.name, zoom_alias.id]
    end
  end

  def show_aliases?(student_attendance)
    !student_attendance.present? && @attendance.respond_to?(:zoom_meeting_id)
  end
end