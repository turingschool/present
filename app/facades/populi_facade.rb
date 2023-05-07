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
    service.get_current_academic_term[:response][:name]
  end

  def student_options
    populi_students.map do |student|
      [student.name, student.personid]
    end
  end

  def best_matching_id(student)
    student_names = populi_students.map {|student| student.name} 
    match_name = find_jarow_match(student.name, student_names)
    populi_students.find do |student|
      student.name == match_name
    end.personid
  end 

  def import_students
    # Refactor: Might want to move this
    self.module.students.destroy_all
    populi_students.each do |student|
      self.module.students.create!(name: student.name, populi_id: student.personid)
    end
  end

  def term_options
    PopuliService.new.get_terms[:response][:academic_term].map do |term|
      [term[:fullname], term[:termid]]
    end
  end

private
  attr_reader :course_id

  def find_matching_module
    current_term_id = service.get_current_academic_term[:response][:termid]
    courses = service.get_courses(current_term_id)[:response][:course_instance]
    course_names = courses.map {|course| course[:abbrv]}
    match = find_jarow_match(@module.name, course_names)
    course_data = courses.find do |course|
      course[:abbrv] == match
    end
    PopuliCourse.new(course_data)
  end

  def populi_students
    @populi_students ||= service.get_students(course_id)[:response][:courseinstance_student].map do |student|
      PopuliStudent.from_populi(student)
    end
  end

  def service
    @service ||= PopuliService.new
  end  
end