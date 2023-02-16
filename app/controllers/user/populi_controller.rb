class User::PopuliController < User::BaseController
  include StringMatcher

  before_action :set_module

  def set_module
    @module = TuringModule.find(params[:turing_module_id])
  end

  def new
    service = PopuliService.new
    current_term_id = service.get_current_academic_term[:response][:termid]
    @courses = service.get_courses(current_term_id)[:response][:course_instance]
    course_names = @courses.map {|course| course[:abbrv]}
    match = find_jarow_match(@module.name, course_names)
    @top_choice = @courses.find do |course|
      course[:abbrv] == match
    end
    @courses -= [@top_choice]
  end  

  def create
    params[:populi_students].each do |student_id, populi_id|
      Student.update(student_id, {populi_id: populi_id})
    end
    redirect_to turing_module_path(@module)
  end

  def match_students
    begin
      @populi_students = PopuliService.new.get_students(params[:course_id])[:response][:courseinstance_student].map do |student|
        PopuliStudent.from_populi(student)
      end
      @populi_student_options = @populi_students.map do |student|
        [student.name, student.personid]
      end
    rescue NoMethodError => error
      @populi_students = nil
      service = PopuliService.new
      @terms = service.get_terms[:response][:academic_term].map do |term|
        [term[:name], term[:termid]]
      end
    end
  end
end