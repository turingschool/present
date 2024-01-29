class PopuliFacade
  include StringMatcher

  attr_reader :module
  
  def initialize(turing_module, course_id = nil, term_id = nil)
    @module = turing_module
    @course_id = course_id
    @term_id = term_id
  end

  def courses
    PopuliService.new.get_term_courses(@term_id)[:response][:course_instance].map do |course_data|
      PopuliCourse.new(course_data)
    end
  end

  def matching_module
    @matching_module ||= find_matching_module
  end

  def current_term_name
    service.get_current_academic_term[:name]
  end

  def import_students
    @module.students.update_all(turing_module_id: nil)
    student_attributes = populi_students.map do |populi_student|
      {name: populi_student.name, populi_id: populi_student.personid, turing_module_id: @module.id}
    end
    Student.upsert_all(student_attributes, unique_by: :populi_id)
  end

  def term_options
    PopuliService.new.get_terms[:data].map do |term|
      [term[:name], term[:id]]
    end
  end

private
  attr_reader :course_id

  def find_matching_module
    current_term_id = service.get_current_academic_term[:id]
    courses = service.get_term_courses(current_term_id)[:response][:course_instance]
    course_names = courses.map {|course| course[:abbrv]}
    match = find_jarow_match(@module.name, course_names)
    course_data = courses.find do |course|
      course[:abbrv] == match
    end
    PopuliCourse.new(course_data)
  end

  def populi_students
    @populi_students ||= service.get_students(course_id)[:body].map do |student|
      PopuliStudent.from_populi(student)
    end
  end

  def service
    @service ||= PopuliService.new
  end  
end