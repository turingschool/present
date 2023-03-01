class User::PopuliController < User::BaseController
  def new
    render locals: {
      facade: PopuliFacade.new(current_module)
    }
  end  

  def create
    PopuliFacade.new(current_module, params[:course_id]).import_students
    redirect_to turing_module_slack_integration_path(current_module)
  end

private
  def current_module
    @current_module ||= TuringModule.find(params[:turing_module_id])
  end
end