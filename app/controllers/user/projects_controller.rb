class User::ProjectsController < User::BaseController
  def index
    @my_module = current_user.my_module
    @projects = Project.all
  end

  def show
    @my_module = current_user.my_module
    @project = Project.find(params[:id])
  end

  def create
    project = Project.new(project_params)
    students = current_user.my_module.students
    if project.save
      project.generate_student_groupings(students)
      flash[:message] = 'Pairings created!'
      redirect_to projects_path
    else
      flash[:error] = "#{project.errors.full_messages.to_sentence}"
      redirect_to projects_path
    end
  end

  private

  def project_params
    params.permit(:name, :size)
  end
end
