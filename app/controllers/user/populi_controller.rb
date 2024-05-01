class User::PopuliController < User::BaseController
  rescue_from ActionView::Template::Error, with: :no_api_response
  
  def new
    render locals: {
      facade: PopuliFacade.new(current_module)
    }
  end  

  def create
    if params[:course_id]
      current_module.update!(populi_course_id: params[:course_id])
      PopuliFacade.new(current_module, params[:course_id]).import_students
      redirect_to turing_module_slack_integration_path(current_module)
    else
      render :terms, locals: {
        facade: PopuliFacade.new(current_module)
      }
    end
  end

  def update
    render :courses, locals: {
      facade: PopuliFacade.new(current_module, nil, params[:term_id])
    }
  end

private
  def current_module
    @current_module ||= TuringModule.find(params[:turing_module_id])
  end

  def no_api_response
    flash[:error] = "Request cannot be fulfilled at this time. This may be due to an unavailable API. Please try again later."
    redirect_to turing_module_path(current_module)
  end
end