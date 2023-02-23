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
end