class AttendanceShowFacade
  include StringMatcher, ApplicationHelper

  attr_reader :attendance, :updatable

  def initialize(attendance, updatable: false)
    @attendance = attendance
    @updatable = updatable
  end
  
  def alias_options_for(student)
    @attendance.turing_module.unclaimed_aliases(@attendance.meeting_id).sort_by do |zoom_alias|
      -1 * string_distance(student.name, zoom_alias.name)
    end.map do |zoom_alias|
      [zoom_alias.name, zoom_alias.id]
    end
  end

  def unassigned_zoom_aliases
    @attendance.turing_module.unclaimed_aliases(@attendance.meeting_id).map { |zoom_alias| zoom_alias.name }.sort
  end

  def student_attendances
    @attendance.student_attendances.includes(:student).where.not(students: { name: "Instructor" }).by_attendance_status
  end

  def instructor_zoom_aliases
    turing_module_id = @attendance.turing_module.id
    if instructor = Student.instructors(turing_module_id).first
      return instructor.zoom_aliases
    else
      return false
    end
  end

  def meeting_title
    @attendance.meeting.title
  end
  
  def meeting_id
    @attendance.meeting.meeting_id
  end

  def turing_module_id
    @attendance.turing_module.id
  end
  
  def thread_link
    @attendance.meeting.message_link
  end
  
  def attendance_date
    pretty_date(@attendance.attendance_time)
  end
  
  def attendance_time
    pretty_time(@attendance.attendance_time)
  end

  def status_count(status)
    @attendance.count_status(status)
  end
end