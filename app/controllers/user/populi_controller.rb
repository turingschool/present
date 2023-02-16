class User::PopuliController < User::BaseController
  def new
    @module = TuringModule.find(params[:turing_module_id])
    service = PopuliService.new
    current_term_id = service.get_current_academic_term[:response][:termid]
    @courses = service.get_courses(current_term_id)[:response][:course_instance]
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    
    @top_choice = @courses.max_by do |course|
      jarow.getDistance(@module.name, course[:abbrv])
    end
    @courses -= [@top_choice]
    @terms = service.get_terms[:response][:academic_term].map do |term|
      [term[:name], term[:termid]]
    end
  end  

  def create
    @module = TuringModule.find(params[:turing_module_id])
    params[:populi_students].each do |student_id, populi_id|
      Student.update(student_id, {populi_id: populi_id})
    end
    redirect_to turing_module_path(@module)
  end

  def index
    @module = TuringModule.find(params[:turing_module_id])
    begin
      @populi_students = PopuliService.new.get_students(params[:course_instance_id])[:response][:courseinstance_student].map do |student|
        ["#{student[:first]} #{"(#{(student[:preferred])}) " if student[:preferred]}#{student[:last]}", student[:personid]]
      end
    rescue NoMethodError => error
      @populi_students = nil
      @terms = PopuliService.new.get_terms[:response][:academic_term][0..5]
    end
  end
end