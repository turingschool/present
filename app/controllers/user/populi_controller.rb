class User::PopuliController < User::BaseController
  def new
    render locals: {
      facade: PopuliFacade.new(current_module)
    }
  end  

  def create
    assign_populi_ids(params[:populi_students])
    redirect_to turing_module_path(current_module)
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
    @current_module ||= TuringModule.find(params[:turing_module_id])
  end

  def assign_populi_ids(populi_students)
    populi_students.each do |student_id, populi_id|
      Student.update(student_id, {populi_id: populi_id})
    end
  end
end