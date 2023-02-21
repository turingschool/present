class User::PopuliController < User::BaseController
  before_action :set_module

  def set_module
    @module = TuringModule.find(params[:turing_module_id])
  end

  def new
    render locals: {
      facade: PopuliFacade.new(@module)
    }
  end  

  def create
    params[:populi_students].each do |student_id, populi_id|
      Student.update(student_id, {populi_id: populi_id})
    end
    redirect_to turing_module_path(@module)
  end

  def match_students
    @terms = PopuliService.new.get_terms[:response][:academic_term].map do |term|
      [term[:name], term[:termid]]
    end

    render locals: {
      facade: PopuliFacade.new(@module, params[:course_id])
    }
  end
end