class User::PopuliController < User::BaseController
  def new
    render locals: {
      facade: PopuliFacade.new(current_module)
    }
  end  

  def create
    @module = TuringModule.find(params[:turing_module_id])
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
      facade: PopuliFacade.new(current_module, params[:course_id])
    }
  end

  private
    def current_module
      TuringModule.find(params[:turing_module_id])
    end
end