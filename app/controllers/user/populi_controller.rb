class User::PopuliController < User::BaseController
  def new
    render locals: {
      facade: PopuliFacade.new(current_module)
    }
  end  

  def create
    # current_module.update(populi_course_id: params[:course_id])
    PopuliFacade.new(current_module, params[:course_id]).import_students
    redirect_to turing_module_slack_integration_path(current_module)
  end

private
  def current_module
    @current_module ||= TuringModule.find(params[:turing_module_id])
  end
end