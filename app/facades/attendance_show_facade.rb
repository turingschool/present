class AttendanceShowFacade
  include StringMatcher

  def initialize(attendance)
    @attendance = attendance
  end

  def unclaimed_aliases_for(student)
    unclaimed_aliases = @attendance.zoom_aliases.where(student: nil).sort_by do |zoom_alias|
      string_distance(student.name, zoom_alias.name)
    end.reverse
    unclaimed_aliases.map do |zoom_alias|
      [zoom_alias.name, zoom_alias.id]
    end
  end
end