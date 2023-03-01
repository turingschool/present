class PopuliService
  def initialize
      PopuliAPI.connect(
          url: ENV["POPULI_API_URL"],  
          access_key: ENV["POPULI_API_ACCESS_KEY"]
      )
  end

  def get_person(id)
      PopuliAPI.get_person(person_id: id)
  end

  def get_courses(term_id)
      PopuliAPI.get_term_course_instances(term_id: term_id)
  end

  def get_current_academic_term
      PopuliAPI.get_current_academic_term
  end

  def get_students(course_instance_id)
      PopuliAPI.get_course_instance_students(instance_id: course_instance_id)
  end

  def get_terms
    PopuliAPI.get_academic_terms
  end

  def get_term_courses(term_id)
    PopuliAPI.get_term_course_instances(term_id: term_id)
  end

  def update_student_attendance(instance_id, meeting_id, person_id, status)

      # instance_id = student_attendance.attendance.turing_module.populi_course_id

      # # REFACTOR: probably need to cache this, and somewhere outside of this service
      # populi_meeting = PopuliAPI.get_course_instance_meetings(instance_id: attendance.turing_module.populi_course_id)[:response][:meeting].min_by do |data|
      #   meeting_time = Time.parse(data[:start])
      #   attendance_time = attendance.zoom_attendance.meeting_time
      #   (attendance_time - meeting_time).abs
      # end
      # meeting_id = populi_meeting[:meetingid]
      # require 'pry';binding.pry
      PopuliAPI.update_student_attendance(instance_id: instance_id, meeting_id: meeting_id, person_id: person_id, status: status)
  end

  def course_meetings(course_id)
    PopuliAPI.get_course_instance_meetings(instance_id: course_id)
  end
end